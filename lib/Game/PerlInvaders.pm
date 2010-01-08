package Game::PerlInvaders;
use 5.010;
use strict;
use warnings;

our $VERSION = 0.002;

use SDL 2.3;
use Game::PerlInvaders::Shared;
use Game::PerlInvaders::Audio;
use Game::PerlInvaders::App;
use Game::PerlInvaders::Events;
use Game::PerlInvaders::Timer;

sub setup {
  Game::PerlInvaders::App::setup_app;
  Game::PerlInvaders::Timer::setup_timer;
  Game::PerlInvaders::Audio::setup_audio;
}

sub run {
  Game::PerlInvaders::Events::loop;
}

42;
