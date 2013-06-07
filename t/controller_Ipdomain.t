use strict;
use warnings;
use Test::More;


use Catalyst::Test 'ActiveCMDB';
use ActiveCMDB::Controller::Ipdomain;

ok( request('/ipdomain')->is_success, 'Request should succeed' );
done_testing();
