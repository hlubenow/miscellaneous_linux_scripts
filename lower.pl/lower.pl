#!/usr/bin/perl

=begin comment

    lower.pl 1.0 - Renames a file, lowering its filenames and
                   stripping problematic characters from it.

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

use Cwd;
use File::Copy;

sub doReplaces {
    my $s = shift;

    my %replaces = (" " => "_",
                    "(" => "",
                    ")" => "",
                    "[" => "",
                    "]" => "",
                    "!" => "",
                    "?" => "",
                    ":" => "",
                    "´" => "",
                    "`" => "",
                    "'" => "",
                    "," => "",
                    '"' => "",
                    "#" => "",
                    "ä" => "ae",
                    "ö" => "oe",
                    "ü" => "ue",
                    "Ä" => "ae",
                    "Ö" => "oe",
                    "Ü" => "ue",
                    "ß" => "sz",
                    "&" => "and");
    my $i;
    for $i (keys(%replaces)) {
        $s =~ s/\Q$i\E/$replaces{$i}/g;
    }
    while ($s =~ m/__/) {
        $s =~ s/__/_/g;
    }
    $s = deletePoints($s);
    return $s;
}

sub deletePoints {
    my $a = shift;
    my @b = split(/\./, $a);
    my $suf;
    my $c;
    if ($#b > 1) {
        $suf = pop(@b);
        $c = join("", @b);
        $c .= ".";
        $c .= $suf;
        return $c;
    } else {
        return $a;
    }
}

if ($#ARGV < 0) {
    print "\nUsage: lower.pl [file]\n\n";
    exit 1;
}

my $f = $ARGV[0];
my $low = lc($f);
$low = doReplaces($low);

my $from_ = getcwd() . "/" . $f;

if (! -e $from_) {
    print "\nFile '$from_' not found. Nothing done.\n\n";
    exit 2;
}

my $to_ = getcwd() . "/" . $low;

if ($from_ eq $to_) {
    print "'$from_': No changes needed.\n";
} else {
    move($from_, $to_) or die "The move operation failed: $!";
    print "$from_ -> $to_\n";
}
