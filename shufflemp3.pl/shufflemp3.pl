#!/usr/bin/perl

=begin comment

    shufflemp3.pl 0.8 - Shuffles mp3-files found in and below the
                        current working directory and plays them
                        with the command  associated with "mpg123".
                        Features direct key-input-control in
                        Linux-terminal.

    Copyright (C) 2009, 2012, hlubenow

    This program is free software: you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    For help, read "perldoc ./shufflemp3.pl" or type "h" at runtime.

=end comment

=cut

use warnings;
use strict;

use Audio::Play::MPG123;
use Term::ReadKey;
use List::Util 'shuffle';
use File::Find;
use File::Basename;
use Cwd 'getcwd';

my $VERSION = 0.8;
my $checkfile = "/media/ramdisk/next";

my $basedir = getcwd();

&Term::ReadKey::ReadMode(4);

my @mp3list = &getMp3List();

my $nrmp3s = @mp3list;

if ($nrmp3s == 0) {
    print "\nNo mp3s found in this directory.\n\n";
    &Term::ReadKey::ReadMode(0);
    exit(1);
}

my @rorder = (0 .. $nrmp3s - 1);
@rorder = shuffle(@rorder);

my $player = Audio::Play::MPG123->new();

print "\nshufflemp3.pl: Press \"h\" for help.\n\n$nrmp3s mp3s found.\n\n";

my $current = 0;
my $song = "";
my $key = "";

while (1) {

    $song = $mp3list[$rorder[$current]];
    $player->load($song);

    print "Playing: " . &File::Basename::basename($song) . "\n";

    # Playback of one song:

    while($player -> state()) {

        $player -> poll(1);

        $key = &Term::ReadKey::ReadKey(-1);

        unless(defined $key) {
            $key = "";
        }

        if ($key eq " ") {

            &Term::ReadKey::ReadMode(0);

            $player -> pause();
           
            print "Pause. Press Return to continue: ";
            <>;
            &Term::ReadKey::ReadMode(4);
            $player -> pause();
        }

        if (ord($key) == 68) {
            # Left
            $player -> jump("-200");
            $player -> poll(1);
            print "Backwards.\n";
        }

        if (ord($key) == 67) {
            # Right
            $player -> jump("+200");
            $player -> poll(1);
            print "Forward.\n";
        }

        if ($key eq "h") {
            &showHelp();
        }

        if ($key eq "n") {
            $player -> stop();
            last;
        }

        # if (-e $checkfile) {
        #    $player -> stop();
        #    unlink $checkfile;
        #    last;
        # }

        if ($key eq "r") {
            $current--;
            $player -> stop();
            last;
        }

        if ($key eq "p") {
            $current -= 2;
            $player -> stop();
            last;
        }

        if ($key eq "c") {
            $player -> pause();
            $current = &certainSong($current);
            $player -> stop();
            last;
        }

        if ($key eq "q") {
            &Term::ReadKey::ReadMode(0);
            $player -> stop();
            $player -> stop_mpg123();
            print "\nBye.\n\n";
            exit(0);
        }
    }

    $current++;

    if ($current < 0) {
        $current = $nrmp3s - 1;
    }

    if ($current == $nrmp3s) {
        $current = 0;
    }
}
         
&Term::ReadKey::ReadMode(0);
$player -> stop_mpg123();
print "\nFinished. All songs played.\n\n";

sub certainSong {

    my $before = shift() - 1;

    &Term::ReadKey::ReadMode(0);

    print "\nPlay certain song:\n\n";

    my $i;

    for $i (0 .. $nrmp3s - 1) {
        print $i + 1 . ". " . &File::Basename::basename($mp3list[$i]) . "\n";
    }

    print "\n";

    my $a = "";

    while($a eq "" || $a =~ /\D/ ||
          $a < 1   || $a > $nrmp3s) {
        print "Song to play ? ";
        chomp($a = <STDIN>);
        if ($a eq "x" || $a eq "q") {
            &Term::ReadKey::ReadMode(4);
            return $before;
        }
    }

    $a--;

    &Term::ReadKey::ReadMode(4);

    for $i (0 .. $#rorder) {
        if ($rorder[$i] == $a) {
            $a = $i - 1;
            last;
        }
    }

    print "\n";

    return $a;
}

sub getMp3List {

    my $descend = 1;
    my $i;

    foreach (@ARGV) {
        if ($_ eq "dir" || $_ eq "-dir") {
            $descend = 0;
            last;
        }
    }

    # Get the names of all files in and
    # under a directory ending with "mp3".

    my %h;

    if ($descend) {

        # Without  File::Type-check:
        # We use a hash to avoid doubles, see "perldoc -q duplicate":

        find({ wanted => sub {if (/\.mp3$/i) {
                              my $fname = $File::Find::fullname;
                              # Strange: Sometimes, $fname is undef or so
                              # and we would get an annoying warning here:
                              if ($fname) {
                                  $h{$File::Find::fullname} = 0;
                              }
         } }, follow_fast => 1, no_chdir => 1 }, $basedir);
    }
    else {
        opendir (DIR, $basedir) || die "Error opening dir $basedir\n";
        while((my $filename = readdir(DIR))){
            my $fullname = "$basedir/$filename";
            if (-f $fullname && $fullname =~ /\.mp3$/i) {
                    $h{$fullname} = 0;
            }
        }
        closedir(DIR);
    }

    # Removing double entries resulting from symbolic links:
    my @a = keys(%h);

    # Now we have a list of the names of all ".mp3"-files. We sort
    # them only by filenames, not by directory-names. But in the end,
    # we return a list containing their exact locations:

    my @b;

    foreach (@a) {
        push(@b, &File::Basename::basename($_));
    }

    @b = sort(@b);

    # We can't use a hash here, because some keys would be double:
    #
    #     /onedir/song.mp3
    # /anotherdir/song.mp3
    #

    my @c;
    my $u;

    for $i (@b) {
        for $u (0 .. $#a) {
            if ($a[$u] =~ m/\Q$i\E$/) {
                push(@c, $a[$u]);
                splice(@a, $u, 1);
                last;
            }
        }
    }

    return @c;
}

sub showHelp {

    my $help = <<HERE;

shufflemp3.pl: Available keys are:

    n           Play next song.
    p           Play previous song.
    LEFT        Go backwards in a song.
    RIGHT       Go forward in a song.
    c           Play certain song.
    SPACE       Pause.
    h           Show (this) help.
    q           Quit.

HERE

    print $help;
    print "Still playing: " . &File::Basename::basename($song) . "\n";
}

__END__

=head1 NAME

shufflemp3.pl - A shuffle-player for mp3-files (for Linux-terminals)

=head1 DESCRIPTION

shufflemp3.pl shuffles mp3-files found in and below the current working directory.

=head1 README

shufflemp3.pl (Linux only) searches in and below the current working directory for files ending with ".mp3", ".MP3", ".Mp3" or ".mP3" and plays them as mp3s with the external command "mpg123" in random order, looping. 

It features direct key-input-control in Linux-terminal.

You may be surprised, which mp3-files are found, when you start it in an unfamiliar directory.

=head1 NOTES

shufflemp3.pl starts just one instance of "mpg123" in remote-control-mode.

By default, the directory is searched recursively, but you can play just the mp3-files inside the directory (but not below it), by starting the script with the "-dir"-option.

Available keys are:

    n           Play next song.
    p           Play previous song.
    LEFT        Go backwards in a song.
    RIGHT       Go forward in a song.
    c           Play certain song.
    SPACE       Pause.
    h           Show help.
    q           Quit.


=head1 CAVEATS

Unusual exits of the script may corrupt your current terminal-settings; just cancel your terminal with "ALT+F4" then and start a new one.

The script tries to find everything that ends with ".mp3", ".MP3", ".Mp3" or ".mP3". It doesn't check, if the files found are really mp3-files. So don't use the script, if you have documents, that are not mp3-files but end with something like ".mp3" (see above) inside or below your current working directory.

=head1 PREREQUISITES

This script requires the following modules:

C<Audio::Play::MPG123>

C<Term::ReadKey>

C<Cwd>

C<File::Find>

C<File::Basename>

C<List::Util>

Also needed is the console-mp3-player "mpg321".

=head1 OSNAMES

linux

=head1 SCRIPT CATEGORIES

Audio/MP3

=head1 AUTHOR

Hauke Lubenow, <hlubenow2@gmx.net>

=head1 COPYRIGHT AND LICENSE

shufflemp3.pl is Copyright (C) 2009-2012, Hauke Lubenow.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl 5.14.2.
For more details, see the full text of the licenses at

<http://www.perlfoundation.org/artistic_license_1_0> and

<http://www.gnu.org/licenses/gpl-2.0.html>.

The full text of the licenses can also be found in the documents L<perldoc perlgpl> and L<perldoc perlartistic> of the official Perl 5.14.2-distribution. In case of any contradictions, these 'perldoc'-texts are decisive.

THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. FOR MORE DETAILS, SEE THE FULL TEXTS OF THE LICENSES MENTIONED ABOVE.

=cut

# Unused Code (which would check with File::Type if the found files are really mp3-files, but this is just too slow for daily-usage):

    # With File::Type-check:

    use File::Type;

    my $fi;
    my $ft = File::Type->new();

    find({ wanted => sub { if ($_ !~ /\.mp3$/i) { return; }
                           $fi = $ft->checktype_filename($_);
                           if ($fi eq "audio/mp3" ||
                               $fi eq "application/octet-stream")
                             { $h{$File::Find::name} = 0; }
                         }, no_chdir => 1 }, $basedir);

