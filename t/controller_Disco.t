use strict;
use warnings;
use Test::More;


use Catalyst::Test 'ActiveCMDB';
use ActiveCMDB::Controller::Disco;

ok( request('/disco')->is_success, 'Request should succeed' );
done_testing();
