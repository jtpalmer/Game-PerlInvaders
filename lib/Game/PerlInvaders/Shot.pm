package Game::PerlInvaders::Shot;
use Moose;

extends 'Game::PerlInvaders::Object';

my $surface;
my $surface_rect;
sub setup {
  $surface = SDL::Image::load('stuff/shot.png' );
  $surface_rect = SDL::Rect->new(0,0,$surface->w,$surface->h);
}

my $speed = 0.5; # pixels per milisecond
sub time_lapse {
  my ($self, $oldtime, $now) = @_;
  my $change = (($now - $oldtime)*$speed);

  if ($self->rect->y - $change > 0) {
    $self->rect(SDL::Rect->new($self->rect->x, $self->rect->y - $change,
                               $self->rect->w, $self->rect->h));
    return 1;
  } else {
    return 0;
  }
}

sub draw {
  my ($self, $window) = @_;
  SDL::Video::blit_surface( $surface, $surface_rect,
                            $window, $self->rect );
}

42;
