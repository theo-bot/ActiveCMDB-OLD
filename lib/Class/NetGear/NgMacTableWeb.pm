package Class::NetGear::NgMacTableWeb;

=begin nd

    Script: Class::NetGear::NgMacTableWeb.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Fetch the mac table for NetGear devices

    About: License

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    
=cut

use v5.16.0;
use Moose::Role;
use File::Basename;
use LWP::UserAgent;
use HTTP::Cookies;
use HTML::Form;
use ActiveCMDB::Common::Constants;
use Logger;

sub discover_ngmactableweb
{
	my ($self, $data) = @_;
	
	my ($ua,$response, $request, $content,$form, $result);
	
	my $url_login  = sprintf("http://%s/base/main_login.html", $self->attr->mgtaddress);
	my $url_table = sprintf("http://%s/base/system/fwd_db.html", $self->attr->mgtaddress);
	
	
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
		
	$request = HTTP::Request->new(POST => $url_login);
	$request->content_type($form->enctype);
	$request->content($content);
	$response = $ua->request($request);
	if ( !$response->is_success ) {
		Logger->warn("Login failed: " . $response->status_line);
		Logger->debug($response->error_as_HTML);
		Logger->debug("Content $content");
		return $result;
	}
	
	$request = HTTP::Request->new(GET => $url_table );
	$response = $ua->request($request);
	if ( !$response->is_success ) {
		Logger->warn("Login failed: " . $response->status_line);
		Logger->debug($response->error_as_HTML);
		Logger->debug("Content $content");
		return $result;
	} 
}