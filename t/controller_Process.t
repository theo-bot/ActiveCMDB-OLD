use strict;
use warnings;
use Test::More;


use Catalyst::Test 'ActiveCMDB';
use ActiveCMDB::Controller::Process;

ok( request('/process')->is_success, 'Request should succeed' );
done_testing();
