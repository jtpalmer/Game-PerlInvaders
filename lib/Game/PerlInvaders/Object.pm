package Game::PerlInvaders::Object;
use Moose;

has 'rect' => (is=>'rw',isa=>'SDL::Rect');

sub time_lapse {
  my ($self, $oldtime, $now) = @_;
  die 'Not implemented.';
}

sub collide {
  my ($self, $other) = @_;
  # collision is harmless by default (should return 0 to remove the object)
  return 1;
}

sub draw {
  my ($self, $surface) = @_;
  die 'Not implemented.';
}

42;
