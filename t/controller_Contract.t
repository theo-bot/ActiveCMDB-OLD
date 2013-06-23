use strict;
use warnings;
use Test::More;


use Catalyst::Test 'ActiveCMDB';
use ActiveCMDB::Controller::Contract;

ok( request('/contract')->is_success, 'Request should succeed' );
done_testing();
