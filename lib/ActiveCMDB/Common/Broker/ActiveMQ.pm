package ActiveCMDB::Common::Broker::ActiveMQ;

=begin nd

    Script: ActiveCMDB::Common::Broker::ActiveMQ.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveMQ plugin for Broker Object

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

use Net::Stomp;
use Logger;
use Data::Dumper;
use ActiveCMDB::Object::Message;
use ActiveCMDB::Common::Constants;
use Try::Tiny;

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
		push($self->{queues}, $dest);
		$result = true;
	} catch {
		Logger->warn("Failed to subscribe to $dest");
	};
	
	return $result;
}

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

sub mq
{
	my($self, $m) = @_;
	
	if ( defined($m) ) {
		$self->{mq} = $m;
	}
	
	return $self->{mq};
}

sub timeout
{
	my($self, $t) = @_;
	if ( defined($t) ) {
		$self->{timeout} = $t;
	}
	return $self->{timeout};
}

1;