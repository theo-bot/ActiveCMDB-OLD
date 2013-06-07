use strict;
use warnings;
use Test::More;


use Catalyst::Test 'ActiveCMDB';
use ActiveCMDB::Controller::Iptype;

ok( request('/iptype')->is_success, 'Request should succeed' );
done_testing();
