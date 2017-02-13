use strict;
use warnings;

use Test::More;
use Pod::Perldoc;
use File::Spec::Functions qw/splitpath splitdir catpath catdir/;

use Module::Build::CleanInstall;

# some CPANtesters use a fresh and not installed version of all dependent modules
if (grep { m#List-MoreUtils.*?blib# } @INC) {
  plan skip_all => "Test irrelevant when not using an installed version of List::MoreUtils";
}

# In distros where List::MoreUtils is a vendor-package, there is no .packlist,
# so ExtUtils::Installed won't see it.  Checking for this case.  If more than one is
# installed, only looking at first result.
my ($L_MU_path) = Pod::Perldoc->new->grand_search_init(['List::MoreUtils']);
if ($L_MU_path) {note 'List::MoreUtils is available'};

# get the _expected_ .packlist directory in a portable way (using File::Spec functions)
my ($vol,$dir,$file) = splitpath ($L_MU_path, 1); #nofile flag
$dir =~ s/.pm$//;
my @dirs = (splitdir($dir));
my @L_MU_only = splice(@dirs, -2, 2);
my $expected_L_MU_packlist_dir = catdir(@dirs, 'auto', @L_MU_only);

if (-e catpath($vol, $expected_L_MU_packlist_dir) &&
    !-e catpath($vol, $expected_L_MU_packlist_dir, '.packlist')) {
  plan skip_all => "Test irrelevant when using distro's vendor-package install of List::MoreUtils";
}

my $packlist = Module::Build::CleanInstall->_get_packlist('List::MoreUtils');
ok ($packlist, 'Found packlist for List::MoreUtils');

ok( 
  ! Module::Build::CleanInstall->_get_packlist('SoMe::ThiNg::NOT::insTalled'), 
  'Returns false on not installed'
);

# ExtUtils::Install::uninstall prints its actions, so create a handle which
# tests from the printed actions

my $unlink_attempted = 0;

{
  package My::Test::Handle;
  use parent 'Tie::Handle';

  sub TIEHANDLE { return bless {}, shift };

  sub PRINT {
    my $self = shift;
    my ($print) = @_;

    $unlink_attempted++ if $print =~ /unlink (.*)/;

    print STDOUT $print;
  }
}

tie *TESTHANDLE, 'My::Test::Handle';
my $stdout = select *TESTHANDLE;
Module::Build::CleanInstall->_uninstall( $packlist, 1 );  # 1 prevents actual removal
select $stdout;

ok( $unlink_attempted, 'At least one simulated unlink attempt was detected' );

done_testing();

