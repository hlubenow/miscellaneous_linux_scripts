#!/usr/bin/perl

my @RADIOS = (

["Fresh80s" , "http://s37.derstream.net/128.mp3"],
["NDR N-Joy", "http://www.ndr.de/resources/metadaten/audio/m3u/n-joy.m3u"],

);

=begin comment

    radioplay.pl 1.1 - Lets you select an internet radio station to play

    Copyright (C) 2021, 2024 hlubenow

    This program is free software: you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

=end comment

=cut

use warnings;
use strict;

use LWP::Simple;

sub getChoice {
    my $x = 0;
    print "\nChoose radio-station:\n\n";
    for my $i (0 .. $#RADIOS) {
        print $i + 1 . ". $RADIOS[$i][0]\n";
    }
    print "\n";
    my $c = "";
    while ($x == 0) {
        print "Choice: ";
        $c = <STDIN>;
        chomp($c);
        if ($c eq "") { next; }
        if ($c eq "q") { print "Bye.\n"; exit 0; }
        if ($c !~ /\D/ && $c >= 1 && $c <= $#RADIOS + 1) {
            $x = 1;
        }
    }
    return $c - 1;
}

sub m3uToMp3 {
    my $url = shift;
    my $contstr = LWP::Simple::get($url);
    chomp($contstr);
    my @a = split(/\n/, $contstr);
    for my $i (@a) {
        chomp($i);
        if ($i =~ m/mp3$/) {
            return $i;
        }
    }
    print "\nError: No mp3 stream found in m3u-file.\n\n";
    exit 1;
}

my $radionr = 0;
if ($#ARGV == 0 && $ARGV[0] !~ /\D/ && $ARGV[0] >= 1 && $ARGV[0] <= $#RADIOS + 1) {
        $radionr = $ARGV[0] - 1;
} else {
    $radionr = &getChoice();
}

my $mp3stream = $RADIOS[$radionr][1];
if ($mp3stream =~ m/m3u$/) {
    $mp3stream = m3uToMp3($mp3stream);
}
print "\nPlaying: $RADIOS[$radionr][0].\n";
my $execstr = "mplayer '$mp3stream' -quiet -nojoystick -af volnorm";
$execstr .= " &>/dev/null";
system($execstr);
print "\n";

