package Logger;

=begin nd

    Script: Logger.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Global logging library

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

	
=cut

use Log::Log4perl;
use base 'Class::Singleton';
use ActiveCMDB::Common;
use ActiveCMDB::ConfigFactory;
use File::Basename;
use Devel::StackTrace;


my $config = ActiveCMDB::ConfigFactory->instance();
$config->load('cmdb');

sub _new_instance {
	my ($self, $args) = @_;

	my $config_file = subst_envvar($config->section('cmdb::logging::config'));
	Log::Log4perl::init_and_watch($config_file);
	Log::Log4perl->wrapper_register(__PACKAGE__);
	
	return $self;
}

sub get_logger
{
	my ($self) = @_;
	return Log::Log4perl->get_logger();
}

sub get_logfile_name
{	
	my $logdir = $config->section('cmdb::logging::logdir');
	$logdir = subst_envvar($logdir);
	my $logfile = basename($0, '.pl');
	$logfile = $logfile . '-' . sprintf("%02d", $ENV{INSTANCE});
	
	return $logdir . '/' . $logfile . '.log';
}

sub AUTOLOAD
{
	my($self, $msg) = @_;
	
	if ( !ref($self) ) {
		$self = __PACKAGE__->instance();
	}
	
	my $caller = ( caller(0) )[0];
	
	my $loglevel = $AUTOLOAD;
	$loglevel =~ s/Logger:://;
	return if $loglevel =~ /DESTROY/;
	
	my $log = Log::Log4perl::get_logger( $caller );
	my $rc = $log->$loglevel($msg);
	if ( $loglevel =~ /error|fatal/ ) {
		my $trace = Devel::StackTrace->new();
		$log->debug($trace->as_string());
	}
	
	return $rc;
}

1;