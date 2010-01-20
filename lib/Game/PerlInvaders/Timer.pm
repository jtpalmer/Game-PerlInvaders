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
use Game::PerlInvaders::Explosion;

my @explosions;
my @enemies;
my $shot;
my $player;
my $time;

my $time_acc = 0;
my $time_acc_ctrl = 0;

# game states:
# 0 - starting
# 1 - playing
# 2 - died
# 3 - won
my $game_state = 0;

sub timer_callback {
  my $now = $Game::PerlInvaders::App::app->ticks;
  my $oldtime = $time;

  my @update_rects;

  if ($game_state != 1) {

    $player ||= Game::PerlInvaders::Player->new(rect => SDL::Rect->new(0, 440, 20, 20));
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

    push @update_rects, SDL::Rect->new(0,0,$Game::PerlInvaders::App::app->w,
                                       $Game::PerlInvaders::App::app->h);

  } elsif ($game_state == 1) {
    lock @Game::PerlInvaders::Shared::event_to_timer;
    while (my $evt = shift @Game::PerlInvaders::Shared::event_to_timer) {
      if ($evt eq 'shoot' && !$shot) {
        $shot = Game::PerlInvaders::Shot->new(rect => SDL::Rect->new($player->rect->x, $player->rect->y,
                                                                     $player->rect->w, $player->rect->h));
      }
    }
  }


  if ($shot) {
    # take care of shot...
    # shots move bottom-up..
    my $old_y = $shot->rect->y;
    my $keep_shot = $shot->time_lapse($oldtime, $now);
    my $s_height = $old_y - $shot->rect->y;

    push @update_rects, SDL::Rect->new($shot->rect->x, $shot->rect->y,
                                       $shot->rect->w, $s_height + $shot->rect->h);
    undef $shot unless $keep_shot;
  }

  if ($player && $Game::PerlInvaders::Shared::keymask) {
    # if there is a keymask it moves sideways
    my $old_x = $player->rect->x;
    $player->time_lapse($oldtime, $now, $Game::PerlInvaders::Shared::keymask);
    my $new_x = $player->rect->x;
    my $change = abs($old_x - $new_x);
    my $actual_x = $old_x <= $new_x ? $old_x : $new_x;

    push @update_rects, SDL::Rect->new($actual_x, $player->rect->y,
                                       $player->rect->w + $change, $player->rect->h);
  }

  if (@enemies) {

    push @update_rects, get_enemies_rects(@enemies);

    @enemies =
      grep {
        $_->time_lapse($oldtime, $now, $shot)
        or do {
          undef $shot;
          push @explosions, Game::PerlInvaders::Explosion->new(rect => SDL::Rect->new($_->rect->x - 33, $_->rect->y - 38,
                                                                                      71,100),
                                                               started => $now);
          0;
        } }
        @enemies;

    push @update_rects, get_enemies_rects(@enemies);

  }

  if (@explosions) {

    push @update_rects, map { $_->rect } @explosions;

    @explosions =
      grep {
        $_->time_lapse($oldtime, $now)
      }
        @explosions;


  }

  $game_state = 3 unless @enemies;
  $game_state = 2 if grep { $_->row > 10 } @enemies;

  Game::PerlInvaders::App::start_frame();

  $player->draw($Game::PerlInvaders::App::app) if $player;
  $shot->draw($Game::PerlInvaders::App::app) if $shot;
  $_->draw($Game::PerlInvaders::App::app) for @enemies;
  $_->draw($Game::PerlInvaders::App::app) for @explosions;

  Game::PerlInvaders::App::end_frame(@update_rects);

  $time = $Game::PerlInvaders::App::app->ticks;

  $time_acc += $time - $now;
  if (++$time_acc_ctrl == $Game::PerlInvaders::Shared::FPS) {
    my $avg = $time_acc / $Game::PerlInvaders::Shared::FPS;
    print "Average time is $avg\n";


    $time_acc = 0;
    $time_acc_ctrl = 0;
  }

  if (int(1000/$Game::PerlInvaders::Shared::FPS) < (0.8 * ($time - $now))) {
    $Game::PerlInvaders::Shared::FPS = int($Game::PerlInvaders::Shared::FPS * 0.9);
    print "Lowering fps to $Game::PerlInvaders::Shared::FPS\n";
  } elsif (int(1000/$Game::PerlInvaders::Shared::FPS) > (3 * ($time - $now))) {
    $Game::PerlInvaders::Shared::FPS = int($Game::PerlInvaders::Shared::FPS * 1.1);
    print "Increasing fps to $Game::PerlInvaders::Shared::FPS\n";
  }

  if ($Game::PerlInvaders::Shared::game_running == 0)
  {
	  return 0;
  }
  return int(1000/$Game::PerlInvaders::Shared::FPS);

}

sub setup_timer {
  Game::PerlInvaders::Enemy::setup;
  Game::PerlInvaders::Shot::setup;
  Game::PerlInvaders::Player::setup;
  Game::PerlInvaders::Explosion::setup;
  $time = $Game::PerlInvaders::App::app->ticks;

  SDL::Time::add_timer(int(1000/$Game::PerlInvaders::Shared::FPS),'main::Game::PerlInvaders::Timer::timer_callback');
}

sub get_enemies_rects {
  my @enemies = @_;
  my @rects;
  return @rects unless @enemies;
  # build a single rect for each row of enemies.
  my $ctrl_y = 0;
  my $ctrl_x_start = 0;
  my $ctrl_x_end = 0;
  my $h;
  for my $enemy (sort { $a->rect->y <=> $b->rect->y || $a->rect->x <=> $b->rect->x } @enemies) {
    $h ||= $enemy->rect->h; # all enemies have the same height;
    if ($ctrl_y && $enemy->rect->y != $ctrl_y) {

      push @rects, build_enemies_rect($ctrl_y, $ctrl_x_start, $ctrl_x_end, $h);

      $ctrl_x_start = $enemy->rect->x;
      $ctrl_y = $enemy->rect->y;
    } elsif (!$ctrl_y) {
      $ctrl_x_start = $enemy->rect->x;
      $ctrl_y = $enemy->rect->y;
    }
    $ctrl_x_end = $enemy->rect->x + $enemy->rect->w;
  }
  push @rects, build_enemies_rect($ctrl_y, $ctrl_x_start, $ctrl_x_end, $h);
  return @rects;
}

sub build_enemies_rect {
  my ($y, $xs, $xe, $h) = @_;
  return SDL::Rect->new($xs, $y,
                        $xe - $xs, $h);
}

42;
