package Game::PerlInvaders::Player;
use Moose;
use POSIX 'ceil';

extends 'Game::PerlInvaders::Object';

my $surface;
my $surface_rect;
sub setup {
  $surface = SDL::Image::load('stuff/onion.png' );
  $surface_rect = SDL::Rect->new(0,0,$surface->w,$surface->h);
}

my $speed = 0.3; # pixels per milisecond

sub time_lapse {
  my ($self, $oldtime, $now, $mask) = @_;
  my $change = ceil(($now - $oldtime)*$speed);

  if (($mask & 1) &&
      (($self->rect->x - $change) > 0)) {
    $self->rect(SDL::Rect->new($self->rect->x - $change, $self->rect->y,
                               $self->rect->w, $self->rect->h));
  } elsif ($mask & 2 &&
           (($self->rect->x + $change) < ($Game::PerlInvaders::Shared::width - $surface_rect->w))) {
    $self->rect(SDL::Rect->new($self->rect->x + $change, $self->rect->y,
                               $self->rect->w, $self->rect->h));
  }
  return 1;
}

sub draw {
  my ($self, $window) = @_;
  SDL::Video::blit_surface( $surface, $surface_rect,
                            $window, $self->rect );
}


42;
