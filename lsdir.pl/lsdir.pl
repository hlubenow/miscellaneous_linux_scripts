#!/usr/bin/perl

=begin comment

    lsdir.pl - Lists the directories in a directory.

    Copyright (C) 2026 hlubenow

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

# Set color to light blue:
print "\033[1;34m";

my @a = <*>;
for my $i (@a) {
    if (-d $i) {
        print "$i\n";
    }
}

# Reset color:
print "\033[0m";
