package Game::PerlInvaders::Timer;
use strict;
use warnings;
use utf8;

use threads;
use threads::shared;

use SDL::Time;

use Game::PerlInvaders::Enemy;
use Game::PerlInvaders::Shot;
use Game::PerlInvaders::Player;

my @enemies;
my $shot;
my $player;
my $time;

# game states:
# 0 - starting
# 1 - playing
# 2 - died
# 3 - won
my $game_state = 0;

sub timer_callback {
  my $now = $Game::PerlInvaders::App::app->ticks;
  my $oldtime = $time;

  if ($game_state != 1) {
    $player = Game::PerlInvaders::Player->new(rect => SDL::Rect->new(0, 450, 20, 20));
    @enemies = ();
    for my $row (1..4) {
      for my $col (1..8) {
        push @enemies,
          Game::PerlInvaders::Enemy->new(row => $row,
                                         state => 0,
                                         rect => SDL::Rect->new(50*$col, 40*$row, 20, 20));
      }
    }

    $game_state = 1;
  } elsif ($game_state == 1) {
    lock @Game::PerlInvaders::Shared::event_to_timer;
    while (my $evt = shift @Game::PerlInvaders::Shared::event_to_timer) {
      if ($evt eq 'shoot' && !$shot) {
        $shot = Game::PerlInvaders::Shot->new(rect => $player->rect);
      }
    }
  }

  $shot->time_lapse($oldtime, $now) or undef $shot
    if $shot;

  $player->time_lapse($oldtime, $now, $Game::PerlInvaders::Shared::keymask)
    if $player;

  @enemies =
    grep { $_->time_lapse($oldtime, $now, $shot) or undef $shot }
      @enemies;

  $game_state = 3 unless @enemies;
  $game_state = 2 if grep { $_->row > 11 } @enemies;

  Game::PerlInvaders::App::start_frame();

  $player->draw($Game::PerlInvaders::App::app) if $player;
  $shot->draw($Game::PerlInvaders::App::app) if $shot;
  $_->draw($Game::PerlInvaders::App::app) for @enemies;

  Game::PerlInvaders::App::end_frame();

  $time = $Game::PerlInvaders::App::app->ticks;
  return int(1000/$Game::PerlInvaders::Shared::FPS);
}

sub setup_timer {
  Game::PerlInvaders::Enemy::setup;
  Game::PerlInvaders::Shot::setup;
  Game::PerlInvaders::Player::setup;
  $time = $Game::PerlInvaders::App::app->ticks;

  SDL::Time::add_timer(int(1000/$Game::PerlInvaders::Shared::FPS),'main::Game::PerlInvaders::Timer::timer_callback');
}

42;
