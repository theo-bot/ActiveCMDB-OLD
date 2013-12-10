package ActiveCMDB::Controller::DevConfig;

=begin nd

    Script: ActiveCMDB::Controller::DevConfig.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Catalyst Controller for Device Configurations

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
	
	This module performs actions on the conversions table
	
	
=cut

use Moose;
use namespace::autoclean;
use ActiveCMDB::Common::Security;
use ActiveCMDB::Object::Device;
use ActiveCMDB::Object::Configuration;

BEGIN { extends 'Catalyst::Controller'; }

sub view :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		my $device_id = $c->request->params->{device_id};
		my $config_id = $c->request->params->{config_id};
	
		my $device = ActiveCMDB::Object::Device->new(device_id => $device_id );
		if ( $device->find() )
		{
			my $config = ActiveCMDB::Object::Configuration->new(device_id => $device_id, config_id => $config_id);
			$config->get_data();
			$config->get_object();
	
			$c->stash->{device}  = $device;
			$c->stash->{devconfig} = $config;
			$c->log->info("Device info loaded " . $config->config_type );
		} else {
			$c->log->warn("Failed to load device info");
		}
		$c->stash->{template} = 'device/device_configobject.tt';
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}


=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
