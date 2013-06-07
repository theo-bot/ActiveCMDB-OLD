use strict;
use warnings;
use Test::More;


use Catalyst::Test 'ActiveCMDB';
use ActiveCMDB::Controller::DevConfig;

ok( request('/devconfig')->is_success, 'Request should succeed' );
done_testing();
