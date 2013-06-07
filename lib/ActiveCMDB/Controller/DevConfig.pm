package ActiveCMDB::Controller::DevConfig;
use Moose;
use namespace::autoclean;
use ActiveCMDB::Object::Device;
use ActiveCMDB::Object::Configuration;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

ActiveCMDB::Controller::DevConfig - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub view :Local {
	my($self, $c) = @_;
	
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
}


=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
