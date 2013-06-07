use strict;
use warnings;
use Test::More;


use Catalyst::Test 'ActiveCMDB';
use ActiveCMDB::Controller::Journal;

ok( request('/journal')->is_success, 'Request should succeed' );
done_testing();
