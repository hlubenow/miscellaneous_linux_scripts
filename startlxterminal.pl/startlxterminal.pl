#!/usr/bin/perl

=begin comment

    startlxterminal.pl 1.0 - Starts a new instance of LXDE's "lxterminal"
                             with a window-title like "Terminal_x" and
                             waits a second, then gives the new window
                             focus using "wmctrl".

    Copyright (C) 2025 hlubenow

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

sub getHighestTerminalNumber {
    my $number = 0;
    my $a = `wmctrl -l`;
    my @b = split("\n", $a);
    my @c; my @d;
    my $i;
    for $i (@b) {
        @c = split(/ /, $i);
        push(@d, pop(@c));
    }
    for $i (@d) {
        if ($i =~ /Terminal_/) {
            @c = split(/_/, $i);
            if ($c[1] > $number) {
                $number = $c[1];
            }
        }
    }
    return $number;
}

# Main:
my $number = getHighestTerminalNumber(); 
# $number has to be by 1 higher than the highest existing terminal-number:
$number++;
my $name = "Terminal_" . $number;
my $e = "lxterminal -t $name &";
system($e);
sleep(1);
$e = "wmctrl -a $name";
system($e);
