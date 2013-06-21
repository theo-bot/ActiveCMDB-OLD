package ActiveCMDB::Common::Broker::ActiveMQ;

=head1 MODULE - ActiveCMDB::Common::Broker::ActiveMQ.pm
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    ActiveMQ plugin for Broker Object

=head1 LICENSE

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

=cut

use Net::Stomp;
use Logger;
use Data::Dumper;
use ActiveCMDB::Object::Message;
use ActiveCMDB::Common::Constants;
use Try::Tiny;

=head2 connect
Connect to a RabbitMQ broker.

=head3 Arguments:
   $self   - Reference to object
   $config - Hash reference with attributes:
 			typeof   - ActiveMQ
 			uri      - Connection URI, ie tcp://127.0.0.1:61613
 			user     - Username
 			password - Password
 			pwencr   - Is the password encrypted (0: No, 1: Yes)
 			prefix   - Default prefix for destinations
 			timeout  - Timeout for message reception

=cut

sub connect {
	my($self, $info) = @_;
	my $result = false;
	foreach $url (split(/\,/, $info->{uri}))
	{
		if ( $url =~ /^tcp:\/\/(.+?):(\d+)/ ) {
			my $host = $1;
			my $port = $2;
			
			Logger->info("Connecting to $host");
			try {
				$self->mq(Net::Stomp->new({ hostname => $host, port => $port }));
				if ( $self->mq ) {
					$self->mq->connect({ login => $info->{user}, passcode => $info->{password} });
					$self->timeout($config->{timeout});
					$result = true;
				}
			} catch {
				Logger->warn("Failed to connect to broker $host:$port\n" . $_);
			};
		}
	}
	return $result;
}

=head2 subscribe

Subscribe to an ActiveMQ queue or topic

=cut

sub subscribe
{
	my($self, $dest) = @_;
	my $result = false;
	
	try {
		$self->mq->subscribe(
			{
				destination				=> $dest,
				'ack'					=> 'client',
				activemq.prefetchSize	=> 1
			}
		);
		push(@{$self->{queues}}, $dest);
		$result = true;
	} catch {
		Logger->warn("Failed to subscribe to $dest");
	};
	
	return $result;
}

=head2 getframe

Get a message from from a ActiveMQ Stomp connection

 Returns
 false - If no frame was available within defined timeout
 $msg  - ActiveCMDB::Object::Message object 

=cut

sub getframe
{
	my($self) = @_;
	
	my($frame, $msg);
	if ( $frame = $self->mq->receive_frame( { timeout => $self->timeout } ))
	{
		$self->mq->ack({ frame => $frame });
		Logger->info("Got a frame \n" . Dumper($frame) );
		my $headers = $frame->headers();
		$msg = ActiveCMDB::Object::Message->new();
		$msg->content_type($frame->{content_type});
		if ( $msg->content_type eq MSG_TYPE_JSON ) {
			Logger->debug("Decoding body");
			$msg->decode_from_json($frame->{body});	
		} else {
			Logger->debug("Unknown content type " . $msg->content_type() );
		}
		return $msg;
	} else {
		Logger->debug("No frame available from $queue");
	}
	return false;
}

=head2 sendframe

Send a message to an ActiveCMDB broker. 

 Arguments:
 $self  - Reference to object
 $msg   - ActiveCMDB::Object::Message object
 $args  - Extra header arguments
 
=cut

sub sendframe
{
	my($self, $msg, $args) = @_;
	my($options, $props);
	
	my $headers = undef;
	foreach my $opt (keys %{$args})
	{
		$headers->{$opt} = $args->{$opt};
	} 
	
	my $frame = Net::Stomp::Frame({ command => 'SEND', headers => $headers, body => $msg->encode_to_json() });
	return $self->mq->send_frame($frame);
}

=head2 mq

Get or set mq attribute, this is the Net::Stomp object.

 Attributes:
 $self - reference to object
 $mq   - Net::Stomp object
 
 Returns:
 $self->{mq} - Net::Stomp object
 
=cut

sub mq
{
	my($self, $mq) = @_;
	
	if ( defined($mq) ) {
		$self->{mq} = $mq;
	}
	
	return $self->{mq};
}

=head2 timeout

Get or Set message reception timeout attribute

 Arguments:
 $self - Reference to object
 $t    - Integer representing time in seconds
 
 Returns
 $self->{timout} - Integer representing time in seconds
 
=cut

sub timeout
{
	my($self, $t) = @_;
	if ( defined($t) ) {
		$self->{timeout} = $t;
	}
	return $self->{timeout};
}

=head2 cmdb_init

Initialize broker connection for ActiveCMDB back-end processing.
 - Subscribe to group queue
 - Subscribe to private queue, ie private to the process
 - Bind queue's to exchanges
 
 Arguments:
 $self - Reference to object
 $args - hash reference with keys like:
 			process   - ActiveCMDB::Object::Process object
 			subscribe - Initiate broker back-end type connection/subscribtion

 In an ActiveCMDB enviroment the broker factory is predefined, ie the clients
 cannot define the queues and/or topics
 
 

=cut

sub cmdb_init
{
	my $broker_config = $self->config->section('cmdb::broker');
	my $process_config = $self->config->section('cmdb::process::'.$args->{process}->name);
	
	my $private_queue = sprintf("%s-%d-%d",
								$self->config->section('cmdb::process::' . $args->{process}->name . '::queue'),
								$args->{process}->server_id,
								$args->{process}->instance
							);
							
	my $group_queue = $self->config->section('cmdb::process::' . $args->{process}->name . '::queue');
	my $common_queue = $self->config->section('cmdb::default::queue');
	
	push( @{ $self->{xchngs} }, $self->{config}->section('cmdb::default::exchange') );
	push( @{ $self->{xchngs} }, $self->{config}->section('cmdb::process::' . $args->{process}->name . '::exchange') );
	
	
	$self->subscribe($group_queue);
	$self->subscribe($private_queue);
	$self->subscribe($common_queue);
}

1;