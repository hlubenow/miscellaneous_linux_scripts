#!/usr/bin/perl

use warnings;
use strict;

=begin comment

    numberconversions.pl 1.2 - Conversions between decimal, hexadecimal
    and binary numbers.

    Copyright (C) 2023 hlubenow

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

my $RIGHTALIGNEMENT = 32;

package NumberConverter {

    sub new {
        my $classname = shift;
        my $self = {};
        return bless($self, $classname);
    }

    sub dec2hex {
        my ($self, $num) = @_;
        return sprintf("%x", $num);
    }

    sub dec2bin {
        my ($self, $num) = @_;
        # "sprintf("%016b", $num)" would create leading zeros to 16 bit,
        # but it gets in the way, when reversing the binary number: 
        return sprintf("%b", $num);
    }

    sub cutHexPrefix {
        my ($self, $num) = @_;
        if ($num =~ /^0[xX]/) {
            $num = substr($num, 2);
        }
        return $num;
    }

    sub hex2dec {
        my ($self, $num) = @_;
        $num = $self->cutHexPrefix($num);
        return hex($num);
    }

    sub hex2bin {
        my ($self, $num) = @_;
        return $self->dec2bin($self->hex2dec($num));
    }

    sub bin2dec {
        my ($self, $num) = @_;
        return oct("0b".$num);
    }

    sub bin2hex {
        my ($self, $num) = @_;
        return $self->dec2hex($self->bin2dec($num));
    }
}


sub askBinDec {
    my $num = shift;
    print "\nIs the number '$num' decimal or binary (d/b) [b]? ";
    my $answer = <STDIN>;
    chomp($answer);
    if ($answer eq "d") {
        return "d";
    } else {
        return "b"
    }
}

sub printT {
    my ($a, $b) = @_;
    my $t = $RIGHTALIGNEMENT - length($a) - length($b);
    print $a . (" " x $t) . "$b\n";
}

sub checkNumber {
    my ($num, $t, $nc) = @_;
    if ($t eq "h") {
        $num = $nc->hex2dec($num);
    }
    if ($t eq "b") {
        $num = $nc->bin2dec($num);
    }
    if ($num <= 65535) {
        return "ok";
    } else {
        return "error";
    }
}

sub getReverseBinNum {
    my $oldbinnum = shift;
    my $binnum    = "";
    my $i;
    my $n;
    my $oldbinnumlen = length($oldbinnum);
    for $i (0 .. $oldbinnumlen - 1) {
        $n = substr($oldbinnum, $i, 1);
        $binnum .= 1 - $n;
    }
    return $binnum;
}

sub printHelp {
    print "\nnumberconversions.pl\n\n";
    print "- Hex-numbers have to be entered with a leading '0x'.\n";
    print "- 'r': Use a reversed version of the previousely entered binary number.\n";
    print "- 'q': Quit.\n\n";
}


my $nc = NumberConverter->new(); 

my $num = "";
my $oldbinnum = "";

if ($#ARGV > -1) {
    $num = $ARGV[0];
}

my $firstloop = 1;
my $t;
my $answer;

my $sep = "\t\t";

while (1) {
    $t = "";
    if ($firstloop == 0 || $num eq "") {
        print "Enter a number ('h' for help): ";
        $num = <STDIN>;
        chomp($num);
    }
    if ($num eq "h") {
        printHelp();
        $num = "";
        next;
    }
    if ($num eq "r") {
        if ($oldbinnum) {
            $num = getReverseBinNum($oldbinnum);
            $oldbinnum = $num;
            $t   = "b";
        } else {
            print "\nError: Reversing a binary number not possible at the moment.\n\n";
            $num = "";
            next;
        }
    }
    $firstloop = 0;
    if ($num eq "q") {
        print "\nBye.\n\n";
        last;
    }
    if ($num =~ /^(0x|0X)/) {
        $t = "h";
        $num = substr($num, 2);
        $oldbinnum = $nc->hex2bin($num);
    }
    if ($num =~ /[^0-9]/) {
        if ($t ne "h" || $num =~ /[^0-9A-Fa-f]/) {
            print "\nError: Wrong format of number '$num'.\n\n";
            next;
        }
    }
    if ($t ne "h" && $num =~ /[2-9]/) {
        $t = "d";
        $oldbinnum = $nc->dec2bin($num);
    }
    if ($t eq "") {
        print "Is '$num' decimal or binary (d/b) [b]? ";
        $answer = <STDIN>;
        chomp($answer);
        if ($answer eq "d") {
            $t = "d";
            $oldbinnum = $nc->dec2bin($num);
        } else {
            $t = "b";
            $oldbinnum = $num;
        }
    }

    if (checkNumber($num, $t, $nc) eq "error") {
        print "\nError: Number '$num' out of range (limit: 65535, 0xffff, 16 bit).\n\n";
        next;
    }

    print "\n";
    if ($t eq "d") {
        printT("Decimal:", $num);
        printT("Hexadecimal:", "0x" . $nc->dec2hex($num));
        printT("Binary:", $nc->dec2bin($num));
    }

    if ($t eq "h") {
        printT("Hexadecimal:", "0x" . $num);
        printT("Decimal:", $nc->hex2dec($num));
        printT("Binary:", $nc->hex2bin($num));
    }

    if ($t eq "b") {
        printT("Binary:", $num);
        printT("Decimal:", $nc->bin2dec($num));
        printT("Hexadecimal:", "0x" . $nc->bin2hex($num));
    }
    print "\n";
}
