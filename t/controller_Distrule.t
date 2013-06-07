use strict;
use warnings;
use Test::More;


use Catalyst::Test 'ActiveCMDB';
use ActiveCMDB::Controller::Distrule;

ok( request('/distrule')->is_success, 'Request should succeed' );
done_testing();
