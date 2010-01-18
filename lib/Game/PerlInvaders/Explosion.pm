package Game::PerlInvaders::Explosion;
use Moose;
use POSIX 'ceil';

extends 'Game::PerlInvaders::Object';

has 'started' => ('is' => 'rw', 'isa' => 'Int');
has 'frame' => ('is' => 'rw', 'isa' => 'Int');

my $surface;
my $surface_rect;
sub setup {
  $surface = SDL::Image::load('stuff/explos-unlicensed.png' );
  $surface_rect = SDL::Rect->new(0,0,$surface->w,$surface->h);
}

my $miliseconds_per_frame = 40;

sub time_lapse {
  my ($self, $oldtime, $now) = @_;

  my $since = $now - $self->started;
  $self->frame(int($since/$miliseconds_per_frame));
  if ($self->frame < 17) {
    return 1;
  } else {
    return 0;
  }
}

sub draw {
  my ($self, $window) = @_;
  SDL::Video::blit_surface( $surface, SDL::Rect->new($self->frame * 71, 0, 71, 100),
                            $window, $self->rect );
}


42;
