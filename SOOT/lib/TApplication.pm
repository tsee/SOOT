package TApplication;
use strict;
use warnings;

sub AsyncRun {
  my $self = shift;

  TApplication::_Util::new_app_thread($self);
  return 1;
}

sub wait {
  my $self = shift;
  require Time::HiRes;
  while (1) {
    last if not $self->IsRunning();
    warn "waiting...";
    Time::HiRes::usleep(50000); # 50 ms
  }
}

package TApplication::_Util;
our @AppThreads;
our %Apps;

sub _apploop {
  my $app = shift;
  $app->SetReturnFromRun(1);
  local %SIG = %SIG;
  $SIG{TERM} = sub {$app->Terminate();};
  $app->Run();
}

sub new_app_thread {
  my $app = shift;

  my $can_use_threads = eval 'use threads; 1';
  return 0 if not $can_use_threads;

  require Time::HiRes;
  require Scalar::Util;

  my $refaddr = "".Scalar::Util::refaddr($app);
  # skip if already running
  if (exists $Apps{$refaddr}) {
    if ($AppThreads[$Apps{$refaddr}]->is_running) {
      return;
    }
    else {
      kill_thread( $AppThreads[$Apps{$refaddr}] );
      $AppThreads[$Apps{$refaddr}] = undef;
      delete $Apps{$refaddr};
    }
  }
  
  $app->SetReturnFromRun(1);
  my $appthr = threads->new(\&_apploop, $app);
  Time::HiRes::usleep(5000); # FIXME find better way to fix this
  $app->SetReturnFromRun(1);

  push @AppThreads, $appthr;
  $Apps{$refaddr} = $#AppThreads;
}

sub kill_thread {
  my $thread = shift;
  return if not defined $thread;
  $thread->kill('TERM');
  Time::HiRes::usleep(10000);
  $thread->kill('KILL')->detach;
}

sub kill_app_threads {
  kill_thread($_) for @AppThreads;
}

END {
  kill_app_threads();
}

1;

