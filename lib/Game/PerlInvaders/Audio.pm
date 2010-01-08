package Game::PerlInvaders::Audio;
use strict;
use warnings;
use utf8;

use threads;
use threads::shared;

use SDL::Constants;
use SDL::Audio;
use SDL::AudioSpec;

my @sequencer;
sub setup_audio {
  my $desired = SDL::AudioSpec->new;
  my $obtained = SDL::AudioSpec->new;
  $desired->callback( 'main::Game::PerlInvaders::Audio::audio_callback'); #canno
  $desired->freq( 11025 );
  $desired->format( AUDIO_U8 );
  $desired->samples( 2048 );
  $desired->channels( 1 );
  die('AudioMixer, Unable to open audio: '.SDL::get_error."\n" ) if ( SDL::Audio::open($desired, $obtained) < 0 );
  SDL::Audio::pause(0);
}

sub audio_callback {
  my ($int_size, $len, $streamref) = @_;

  # produce noise if the ship is moving...
  my $noise_amp = 0.2;

  for my $i (0..($len-1)) {
    # this should be the result value (-1 to +1) of this sample
    my $val = 0;

    if ($Game::PerlInvaders::Shared::keymask) {
      $val += rand($noise_amp);
    }

    $val = int($val * 100) + 0x80; # this is the center...
    $val = 0 if $val < 0;
    $val = 255 if $val > 255;

    substr($$streamref, $i, 1, chr($val));
  }

}



42;
