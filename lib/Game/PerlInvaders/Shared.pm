package Game::PerlInvaders::Shared;

use threads;
use threads::shared;

our $keymask :shared;
our @event_to_timer :shared;
our $FPS :shared;
our $width :shared;
our $height :shared;
our $game_running :shared;

$FPS = 30;
$keymask = 0;
@event_to_timer = ();
$width = 640;
$height = 480;

$game_running = 1;

1;
