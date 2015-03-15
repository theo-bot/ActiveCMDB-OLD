use strict;
use warnings;
use Test::More;


use Catalyst::Test 'ActiveCMDB';
use ActiveCMDB::Controller::Compliance;

ok( request('/compliance')->is_success, 'Request should succeed' );
done_testing();
