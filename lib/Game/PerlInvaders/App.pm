package Game::PerlInvaders::App;
use strict;
use warnings;
use utf8;

use threads;
use threads::shared;

use SDLx::App;
use SDL::Image;
use SDL::Video;

our $app;
our $app_rect;

my $bg;

sub setup_app {
  $app = SDLx::App->new
    ( width  => $Game::PerlInvaders::Shared::width,
      height => $Game::PerlInvaders::Shared::height,
      depth  => 16 );
  $bg = SDL::Image::load('stuff/stars.png');
  $app_rect = SDL::Rect->new(0, 0, $bg->w, $bg->h);
}

sub start_frame {
  SDL::Video::blit_surface( $bg, $app_rect,
                            $app, $app_rect );
}

sub end_frame {
  return unless @_;
  SDL::Video::update_rects($app, @_);
}

42;

