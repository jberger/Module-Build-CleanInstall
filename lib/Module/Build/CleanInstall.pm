package Module::Build::CleanInstall;

use strict;
use warnings;

use parent 'Module::Build';
use ExtUtils::Install qw/uninstall/;
use ExtUtils::Installed;

sub ACTION_install {
  my $self = shift;
  my $module = $self->module_name;

  my $installed = ExtUtils::Installed->new;
  if ( my $packlist = eval { $installed->packlist($module)->packlist_file } ) {
    uninstall($packlist);
  }

  $self->SUPER::ACTION_install;
}


