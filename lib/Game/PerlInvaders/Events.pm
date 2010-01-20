package Game::PerlInvaders::Events;
use strict;
use warnings;
use utf8;

use threads;
use threads::shared;

use SDL;
use SDL::Event;
use SDL::Events;

sub stop_game
{

	lock $Game::PerlInvaders::Shared::game_running;
	$Game::PerlInvaders::Shared::game_running = 0;
}

sub loop {
  my $sevent = SDL::Event->new;
   
  while (SDL::Events::wait_event($sevent) && $Game::PerlInvaders::Shared::game_running) {
    my $type = $sevent->type;
    if ($type == SDL_QUIT()) {
      stop_game;

    } elsif ($type == SDL_KEYDOWN() &&
             $sevent->key_sym() == SDLK_ESCAPE) {
      stop_game;

    } elsif ($type == SDL_KEYDOWN() &&
             $sevent->key_sym() == SDLK_F11) {
      SDL::Video::wm_toggle_fullscreen($Game::PerlInvaders::App::app);

    } elsif ($type == SDL_VIDEORESIZE()) {
      lock $Game::PerlInvaders::Shared::width;
      lock $Game::PerlInvaders::Shared::height;
      $Game::PerlInvaders::App::app->resize($sevent->resize_w, $sevent->resize_h);
      $Game::PerlInvaders::Shared::height = $Game::PerlInvaders::App::app->h;
      $Game::PerlInvaders::Shared::width = $Game::PerlInvaders::App::app->w;

    } elsif ($type == SDL_KEYDOWN() &&
             $sevent->key_sym() == SDLK_SPACE) {
      lock @Game::PerlInvaders::Shared::event_to_timer;
      push @Game::PerlInvaders::Shared::event_to_timer, 'shoot';

    } elsif ($type == SDL_KEYDOWN &&
             $sevent->key_sym() == SDLK_LEFT) {
      lock $Game::PerlInvaders::Shared::keymask;
      $Game::PerlInvaders::Shared::keymask |= 1;

    } elsif ($type == SDL_KEYUP &&
             $sevent->key_sym() == SDLK_LEFT) {
      lock $Game::PerlInvaders::Shared::keymask;
      $Game::PerlInvaders::Shared::keymask &= ~1;

    } elsif ($type == SDL_KEYDOWN &&
             $sevent->key_sym() == SDLK_RIGHT) {
      lock $Game::PerlInvaders::Shared::keymask;
      $Game::PerlInvaders::Shared::keymask |= 2;

    } elsif ($type == SDL_KEYUP &&
             $sevent->key_sym() == SDLK_RIGHT) {
      lock $Game::PerlInvaders::Shared::keymask;
      $Game::PerlInvaders::Shared::keymask &= ~2;
    }
  }
}

42;
