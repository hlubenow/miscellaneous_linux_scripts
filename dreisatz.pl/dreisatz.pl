#!/usr/bin/perl

=begin comment

    dreisatz.pl 1.0 - Caculates "rule of three"

    Copyright (C) 2021 hlubenow

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

sub checkNumber {
    my $n = shift;
    my $a = shift;
    my $b = $a;
    my $e = 0;
    $b =~ s/,/./g;
    my $points = ($b =~ tr/\.//);
    if ($points > 1) {
        $e = 1;
    }
    $b =~ s/\.//g;
    if ($b =~ m/\D/) {
        $e = 1;
    }
    if ($e == 1) {
        print "\nError: Command line option " . (ord($n) - 96) . " ('$a') was not a number.\n\n";
        exit 2;
    }
}

sub printOutput {
    my $s = shift;
    my %h = %{shift()};
    print "\nDreisatz, $s:\n\n";
    print $h{a} . "\t|\t" . $h{b} . "\n";
    print $h{c} . "\t|\t" . $h{d} . "\n";
    print "\n";
}

if ($#ARGV < 2) {
    print "\nError: Not enough command line options.\n";
    print "\nUsage: dreisatz.pl [a] [b] [c] [\"anti\"]\n\n";
    exit 1;
}

my %h = ();
$h{a} = $ARGV[0];
$h{b} = $ARGV[1];
$h{c} = $ARGV[2];

my $i;
for $i (keys(%h)) {
    checkNumber($i, $h{$i});
}

my $antiprop = 0;

if ($#ARGV >= 3 && $ARGV[3] =~ m/anti/i) {
    $antiprop = 1;
}

if ($antiprop == 0) {
    $h{d} = $h{b} * $h{c} / $h{a};
    printOutput("proportional", \%h);
} else {
    $h{d} = $h{b} * $h{a} / $h{c};
    printOutput("antiproportional", \%h);
}
