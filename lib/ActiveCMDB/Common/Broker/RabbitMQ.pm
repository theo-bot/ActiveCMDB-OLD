package ActiveCMDB::Common::Broker::RabbitMQ;

=begin nd

    Script: ActiveCMDB::Common::Broker::RabbitMQ.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    RabbitMQ plugin for Broker Object

    About: License

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    Topic: Release information

    $Rev$

	Topic: Description
	
	
	
	
=cut

use Net::RabbitMQ;
use Logger;
use Data::Dumper;
use ActiveCMDB::Object::Message;
use ActiveCMDB::Common::Constants;

use constant MQ_CHANNEL     => 1;
use constant MQ_ROUTING_KEY => '';

my $queue_name = '';

sub connect {
	my($self, $config) = @_;

	Logger->info("Conneting to broker");
	
	#
	# Disable SIGPIPE to avoid unexpected exits
	$SIG{'PIPE'} = 'IGNORE';
	
	foreach $url (split(/\,/, $config->{uri})) 
	{
		if ( $url =~ /^tcp:\/\/(.+):(\d+)/ ) {
			my $host = $1;
			my $port = $2;
			Logger->info("Connecting to $host:$port");
			$self->mq(Net::RabbitMQ->new());
			eval {
				$self->mq->connect($host, { 
											user	 => $config->{user}, 
											password => $config->{password},
											port	 => $port 
										  }
									);
			};
			if ( $@ ) {
				Logger->error("Failed to connect to $host");
				Logger->error($@);
			} else {
				Logger->info("Opening primary channel");
				$self->mq->channel_open(MQ_CHANNEL);
				last;
			}
		} else {
			Logger->fatal("Unable to connect to broker framework.");
		}
	}
}

sub subscribe
{
	my($self, $queue) = @_;
	
	push(@{$self->{queues}}, $queue);
	Logger->info("Declaring non-durable queue $queue");
	$self->mq->queue_declare(MQ_CHANNEL, $queue, { durable => 0} );
}

sub getframe {
	my($self) = @_;
	my($frame, $msg);
	
	#
	# Get a frame from the global queue
	#
	
	foreach my $queue ( @{ $self->{queues} } )
	{
		Logger->debug("Receiving frame from queue $queue");
		$frame = $self->mq->get(MQ_CHANNEL, $queue );
		if ( defined($frame) ) {
			Logger->debug("Got a frame \n" . Dumper($frame) );
			$msg = ActiveCMDB::Object::Message->new();
			$msg->content_type($frame->{props}->{content_type});
			if ( $msg->content_type eq MSG_TYPE_JSON ) {
				Logger->debug("Decoding body");
				$msg->decode_from_json($frame->{body});
			} else {
				Logger->debug("Unknown content type " . $msg->content_type() );
			}
			return $msg
		} else {
			Logger->debug("No frame available from $queue")
		}
	}
	
	return false;
}

sub sendframe {
	my($self, $msg, $args) = @_;
	my($options, $props);
	
	#Logger->debug(Dumper($msg));

	$props = { content_type => MSG_TYPE_JSON };
	if ( defined($args) )
	{
		if ( defined($args->{priority}) ) {
			$props->{priority} = $args->{priority};		
		}
	}
	
	#
	# Publish the message
	#
	Logger->info("Publish message to ".$msg->to);
	
	if ( $msg->to =~ /^.+-x$/ ) {
		
		#
		# Send message to exchange
		#
		
		$options = { exchange => $msg->to };
		$self->create_exchange($msg->to);
		$msg->ts1(time());
		$self->mq->publish(MQ_CHANNEL, '', $msg->encode_to_json(),$options, $props);
	} else {
		
		#
		# Send message to queue
		#
		$self->mq->publish(MQ_CHANNEL, $msg->to ,$msg->encode_to_json(),$options, $props )
	}
	
}

sub disconnect {
	$mq->disconnect();
	$mq = undef;
}

sub mq {
	my($self, $mq) = @_;
	
	if ( defined($mq) ) {
		$self->{mq} = $mq;
	}
	
	return $self->{mq};
}

sub create_exchange {
	my($self, $xchng) = @_;
	
	if ( defined($xchng) && length($xchng) > 2 ) {
		Logger->info("Declaring exchange $xchng");
		$self->mq->exchange_declare(MQ_CHANNEL, $xchng, { durable => 1 });
	} else {
		Logger->warn("Inavlid exchange name");
	}
}

sub cmdb_init {
	my($self, $args ) = @_;
	
	my $broker_config = $self->config->section('cmdb::broker');
	my $process_config = $self->config->section('cmdb::process::'.$args->{process}->name);
	
	my $private_queue = sprintf("%s-%d-%d",
								$self->config->section('cmdb::process::' . $args->{process}->name . '::queue'),
								$args->{process}->server_id,
								$args->{process}->instance
							);
							
	my $group_queue = $self->config->section('cmdb::process::' . $args->{process}->name . '::queue');
	
	push( @{ $self->{xchngs} }, $self->{config}->section('cmdb::default::exchange') );
	push( @{ $self->{xchngs} }, $self->{config}->section('cmdb::process::' . $args->{process}->name . '::exchange') );
	
	
	$self->subscribe($group_queue);
	$self->subscribe($private_queue);
	
	
	#
	# Declare exchanges
	#
	foreach my $xchng ( @{$self->{xchngs}} )
	{
		$self->create_exchange($xchng);
	}
	
	# Bind queue to exchanges
	Logger->debug("Binding to exchanges to private queue $private_queue");
	foreach my $xchng ( @{ $self->{xchngs} } )
	{
		Logger->debug("Binding $xchng");
		$self->mq->queue_bind(MQ_CHANNEL, $private_queue, $xchng, MQ_ROUTING_KEY);
	}
}
1;