#!/usr/bin/perl

=begin comment

    mehrwertsteuer.pl 1.0 - Calculates German "Mehrwertsteuer" 

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

sub betragValid {
    my $a = shift;
    $a =~ s/,/./g;
    my $points = ($a =~ tr/\.//);
    if ($points > 1) {
        return 0;
    }
    $a =~ s/\.//g;
    if ($a =~ m/\D/) {
        return 0;
    }
    return 1;
}

if ($#ARGV < 0) {
    print "\nUsage: mwst.pl [Betrag]\n\n";
    exit 1;
}

my $mwsts      = 19;
my $linelength = 40;

my $betrag = $ARGV[0];

if (betragValid($betrag) == 0) {
    print "\nError: Invalid value.\n\n";
    exit 2;
}

sub align {
    my @a = @_;
    my $i;
    my $c;
    # Iterator as l-value manipulates list directly (in Perl):
    for $i (@a) {
        if ($i eq "") {
            next;
        }
        $i .= " EUR";
        $c = " " x ($linelength - length($i));
        $i =~ s/\t/$c/;
        $i =~ s/\./,/g;
    }
    return @a;
}

$betrag =~ s/,/./g;
my @a = ();
my $s = "Netto:\t" . sprintf("%.2f", $betrag);
push(@a, $s);
$s = "Mehrwertsteuer ($mwsts%)\t" . sprintf("%.2f", $betrag * $mwsts / 100);
push(@a, $s);
$s = "Brutto:\t" . sprintf("%.2f", $betrag * (100 + $mwsts) / 100);
push(@a, $s);
push(@a, "");
$s = "Brutto:\t" . sprintf("%.2f", $betrag);
push(@a, $s);
$s = "Mehrwertsteuer ($mwsts%)\t" . sprintf("%.2f", $betrag * $mwsts / (100 + $mwsts));
push(@a, $s);
$s = "Netto:\t" . sprintf("%.2f", $betrag * 100 / (100 + $mwsts));
push(@a, $s);

@a = align(@a);

my $i;
print "\n";
for $i (@a) {
    print "$i\n";
}
print "\n";
