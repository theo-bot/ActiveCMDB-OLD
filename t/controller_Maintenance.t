use strict;
use warnings;
use Test::More;


use Catalyst::Test 'ActiveCMDB';
use ActiveCMDB::Controller::Maintenance;

ok( request('/maintenance')->is_success, 'Request should succeed' );
done_testing();
