package Class::NetGear::FetchConfigWeb;

=begin nd

    Script: Class::NetGear::FetchConfigWeb.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Configuration fetcher methods for NetGear devices

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
	
	This a helper to discover the os version on netgear operations
	
	
=cut

use v5.16.0;
use Moose::Role;
use File::Basename;
use LWP::UserAgent;
use HTTP::Cookies;
use HTML::Form;
use ActiveCMDB::Common::Constants;
use Logger;

sub FetchConfigWeb
{
	my ($self, $landing) = @_;
	my ($ua,$response, $request, $content,$form, $result);
	my ($file,$mode, $tftp_file);
	
	Logger->info("Downloading config via Web Form");
	
	#
	# Define result
	#
	$result = undef;
	$result->{filenum} = 1;
	$result->{complete} = false;
	@{$result->{files}} = ();
	
	#
	# Create file
	#
	$file = sprintf("%s/%s.conf",$landing->{directory}, $self->attr->hostname);
	$mode = 0666;
	open(TMP, ">", $file);
	close(TMP);
	
	#
	# Set right permissions
	#
	chmod $mode, $file;
	$tftp_file = basename($file);
	
	if ( defined($file) && defined($landing->{netaddr}) )
	{
	
		my $url_login  = sprintf("http://%s/base/main_login.html", $self->attr->mgtaddress);
		my $url_upload = sprintf("http://%s/base/system/file_upload.html", $self->attr->mgtaddress);
	
	
		my $cookie_file = sprintf("%s/var/tmp/lwpcookies.%s.txt", $ENV{CMDB_HOME}, $ENV{CMDB_INSTANCE});
	
		$ua = LWP::UserAgent->new();
		$ua->cookie_jar(HTTP::Cookies->new(file => $cookie_file, autosave =>1));
	
		#
		# Request login page
		#
		$request = HTTP::Request->new(GET => $url_login);
		$response = $ua->request($request);
		if ( !$response->is_success ) {
			Logger->warn("Failed to request login form: " . $response->status_line);
			Logger->debug("\n" . $response->error_as_HTML);
			return $result;
		}
	
		$form = HTML::Form->parse($response);
		#
		# Login via form
		#
		$content  = sprintf("pwd=%s", $self->attr->telnet_pwd);
		
		$request = HTTP::Request->new(POST => $url_upload);
		$request->content_type($form->enctype);
		$request->content($content);
		$response = $ua->request($request);
		if ( !$response->is_success ) {
			Logger->warn("Login failed: " . $response->status_line);
			Logger->debug($response->error_as_HTML);
			Logger->debug("Content $content");
			return $result;
		}
	
		#
		# Request upload form
		#
		$request = HTTP::Request->new(GET => $url_upload);
		$response = $ua->request($request);
		if ( $response->is_error ) {
			Logger->warn("Failed to request upload form: " . $response->status_line);
			Logger->debug($response->error_as_HTML);
			return $result;
		}
		$form = HTML::Form->parse($response);
		#
		# Upload config to sever
		#
		$request = HTTP::Request->new(POST => $url_upload);
		$request->content_type($form->enctype);
		$content  = sprintf("file_type=%s", 'txtcfg');
		$content .= sprintf("&transfer_protocol=%s",'TFTP');
		$content .= sprintf("&server_addr_type=%s", 'IPv4');
		$content .= sprintf("&server_addr=%s",$landing->{netaddr});
		$content .= sprintf("&filepath=");
		$content .= sprintf("&filename=%s",$tftp_file );
		$content .= sprintf("&start=on");
		$content .= sprintf("&txstatus=%s", $form->find_input('txstatus')->value);
		$content .= sprintf("&saved_localfilename=%s", $form->find_input('saved_localfilename')->value);
		$content .= sprintf("&err_flag=%s", $form->find_input('err_flag')->value);
		$content .= sprintf("&err_msg=%s", $form->find_input('err_msg')->value);
		$content .= sprintf("&submt=16");
		$content .= sprintf("&cncel=");
		$content .= sprintf("&refrsh=");
	
		$request->content($content);
		$response = $ua->request($request);
		if ( ! $response->is_success ) {
			Logger->warn("Upload failed: " . $response->status_line);
			Logger->debug("\n" . $response->error_as_HTML);
			return $result;
		}
	
		#
		# Store the results 
		#
		my $filedata = undef;
		$filedata->{filename} = $file;
		$filedata->{filetype} = 'ASCII';
		push(@{$result->{files}},$filedata);
		$result->{complete} = true;
		
		#
		# Request login page, to logout
		#
		$request = HTTP::Request->new(GET => $url_login);
		$response = $ua->request($request);
		if ( !$response->is_success ) {
			Logger->warn("Failed to request login form: " . $response->status_line);
			Logger->debug($response->error_as_HTML);
		}
	} else {
		Logger->warn("Filename not defined") if ( !defined($file) );
		Logger->error("TFTP Server not defined") if ( !defined($landing->{netaddr}) )		
	}
	
	return $result
}

1;