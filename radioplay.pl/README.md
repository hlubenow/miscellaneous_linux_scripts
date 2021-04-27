#### radioplay.pl

This script lets you select an internet radio station to play.
When you start the script without options, a list is presented, from which you can
select a number.
When you already know the number of the radio station in the list, you can also pass the number directly as a command line option to the script.

Right now, the list just contains two example radio stations. The idea is, that you add more stations to your taste into the array at the beginning of the script. The format is relatively easy to understand.
Just add lines in this format:

`["Radio Station Name", "Playlist URL"],`

Don't forget the comma at the end of the line.

To get the m3u file and read out the mp3-lines contained within, the script uses the Perl-module "[LWP::Simple](
https://metacpan.org/pod/LWP::Simple)". It's probably part of your Linux distribution, so look for it in the distribution's package manager.

License: GNU GPL 3 (or higher)
