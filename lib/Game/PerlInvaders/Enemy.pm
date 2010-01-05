package Game::PerlInvaders::Enemy;
use Moose;

extends 'Game::PerlInvaders::Object';

my $surface;
my $surface_rect;
sub setup {
  $surface = SDL::Image::load('stuff/enemy.png' );
  $surface_rect = SDL::Rect->new(0,0,$surface->w,$surface->h);
}

# states are:
# 0 - left to right
# 1 - top to bottom in the right corner
# 2 - right to left
# 3 - top to bottom in the left corner
has 'state' => (is => 'rw', isa => 'Int');
has 'row' => (is => 'rw', isa => 'Int');

my $speed = 0.05; # pixels per milisecond
my $speed_mod = 0.6; # final speed increment
my $row_height = 40;

sub time_lapse {
  my ($self, $oldtime, $now, $shot) = @_;

  my $change = int((($now - $oldtime)*($speed+($speed_mod*($self->row / 12))))+0.5);

  if ($self->state == 0) {

    my $limit = $Game::PerlInvaders::Shared::width - $self->rect->w;
    my $dest = $self->rect->x + $change;

    if ($dest < $limit) {
      $self->rect(SDL::Rect->new($dest, $self->rect->y,
                                 $self->rect->w, $self->rect->h));
    } else {
      my $left = $dest - $limit;
      $self->rect(SDL::Rect->new($limit, $self->rect->y + $left,
                                 $self->rect->w, $self->rect->h));
      $self->state(1)
    }
  } elsif ($self->state == 1 || $self->state == 3) {

    my $limit = ($row_height * ($self->row + 1));
    my $dest = ($self->rect->y + $change);

    if ($dest < $limit) {
      $self->rect(SDL::Rect->new($self->rect->x, $dest,
                                 $self->rect->w, $self->rect->h));
    } else {
      my $left = $dest - $limit;

      $self->row($self->row + 1);
      if ($self->state == 1) {
        $self->rect(SDL::Rect->new($self->rect->x - $left, $limit,
                                   $self->rect->w, $self->rect->h));
        $self->state(2);
      } else {
        $self->rect(SDL::Rect->new($self->rect->x + $left, $limit,
                                   $self->rect->w, $self->rect->h));
        $self->state(0);
      }
    }
  } else {

    my $dest = ($self->rect->x - $change);

    if ($dest > 0) {
      $self->rect(SDL::Rect->new($dest, $self->rect->y,
                                 $self->rect->w, $self->rect->h));
    } else {
      my $left = 0 - $dest;

      $self->rect(SDL::Rect->new(0, $self->rect->y + $left,
                                 $self->rect->w, $self->rect->h));
      $self->state(3)
    }
  }

  if ($self->hit($shot)) {
    return 0;
  } else {
    return 1;
  }
}

sub draw {
  my ($self, $window) = @_;
  SDL::Video::blit_surface( $surface, $surface_rect,
                            $window, $self->rect );
}

sub hit {
  my ($self, $shot) = @_;
  return 0 unless $shot;

  my $r1 = $self->rect;
  my $r2 = $shot->rect;

  my $r1x1 = $r1->x;
  my $r1y1 = $r1->y;

  my $r1x2 = $r1->x + $r1->w;
  my $r1y2 = $r1->y + $r1->h;

  my $r2x1 = $r2->x;
  my $r2y1 = $r2->y;

  my $r2x2 = $r2->x + $r2->w;
  my $r2y2 = $r2->y + $r2->h;

  return 0 if ($r2y2 < $r1y1);
  return 0 if ($r1y2 < $r2y1);

  return 0 if ($r2x2 < $r1x1);
  return 0 if ($r1x2 < $r2x1);

  return 1;
}

42;
