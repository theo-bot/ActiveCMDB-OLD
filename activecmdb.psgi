use strict;
use warnings;

use ActiveCMDB;

my $app = ActiveCMDB->apply_default_middlewares(ActiveCMDB->psgi_app);
$app;

