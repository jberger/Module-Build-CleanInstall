package Module::Build::CleanInstall;

use strict;
use warnings;

use parent 'Module::Build';
use ExtUtils::Installed;

sub ACTION_uninstall {
  my $self = shift;
  my $module = $self->module_name;

  if ( my $packlist = $self->_get_packlist($module) ) {
    print "Removing old copy of $module\n";
    $self->_uninstall($packlist);
  }
}

sub ACTION_install {
  my $self = shift;
  $self->depends_on('uninstall');
  $self->SUPER::ACTION_install;
}

sub _get_packlist {
  my $self = shift;
  my ($module) = @_;

  my $installed = ExtUtils::Installed->new;
  my $packlist = eval { $installed->packlist($module)->packlist_file };

  return $packlist || '';
}

sub _uninstall {
  my $self = shift;
  my ($packlist, $dont_execute) = @_;

  require ExtUtils::Install;
  ExtUtils::Install::uninstall( $packlist, 1, !!$dont_execute );
}
