#!/usr/bin/perl

use warnings;
use strict;

use Cwd;

=begin comment

    makecrypt.pl 1.0 - May create an encypted data container
                       on certain Linux distributions.
                       Works for me on OpenSuSE Linux 13.1 (32bit).

    Copyright (C) 2021 Hauke Lubenow, Germany

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

# Variable settings: These need to be edited by the user:

my $CONTAINERFILE      = "/home/user/newcryptfile";
my $SAFEDIRECTORY      = "/home/user/newsafe";
my $CONTAINERSIZE      = 2;
my $SIZETYPE           = "MB";
my $PASSWORD           = "test";
my $MOSAFILENAME       = "mosa_new";
my $UMOSAFILENAME      = "umosa_new";


# -----

sub checkVariablesEdited {
    my $var    = shift;
    my $defval = shift;
    my $vname  = shift;
    if ($var eq $defval) {
        print "Error: Variable '\$$vname' wasn't edited. Nothing done.\n";
        print "\n(You're supposed to open the Perl script in an editor,\n";
        print "and edit the variable settings at its top according to your needs.)\n\n";
        exit 3;
    }
}

sub checkFileExists {
    my $fname = shift;
    if (-e $fname) {
        print "'$fname' already exists. Nothing done.\n\n";
        exit 4;
    }
}

sub checkForYes {
    my $inp = <STDIN>;
    chomp($inp);
    print "\n";
    if ($inp ne "y") {
        print "Bye.\n\n";
        exit 0;
    }
}

sub writefile {
    my $fname   = shift;
    my @content = @{ shift() };
    open(my $fh, ">", $fname) or die $!;
    for my $i (@content) {
        print $fh "$i\n";
    }
    system("chmod +x $fname");
    print "'$fname' written\n";
}

# Main:

print "\nmakecrypt.pl\n\n";

if ( $> != 0 ) {
    print "Error: This script must be run as user 'root'.\n\n"; 
    exit 1;
}

if ($SIZETYPE ne "MB" && $SIZETYPE ne "GB") {
    print "Error: Invalid SIZETYPE.\n\n";
    exit 2;
}

checkVariablesEdited($CONTAINERFILE,
                     "/home/user/newcryptfile",
                     "CONTAINERFILE");

checkVariablesEdited($SAFEDIRECTORY,
                     "/home/user/newsafe",
                     "SAFEDIRECTORY");

checkFileExists($CONTAINERFILE);
checkFileExists($SAFEDIRECTORY);

$MOSAFILENAME  = getcwd() . "/$MOSAFILENAME";
$UMOSAFILENAME = getcwd() . "/$UMOSAFILENAME";

print "Settings:\n\n";
print "Container-file:\t$CONTAINERFILE\n";
print "Safe directory:\t$SAFEDIRECTORY\n";
print "Container size:\t$CONTAINERSIZE $SIZETYPE\n";
print "Password:\t$PASSWORD\n";
print "mosa filename:\t$MOSAFILENAME\n";
print "umosa filename:\t$UMOSAFILENAME\n\n";

print "Proceed with these settings (y/n)? ";
checkForYes();

checkFileExists($MOSAFILENAME);
checkFileExists($UMOSAFILENAME);

my @commands = ("modprobe cryptoloop");
push(@commands, "mkdir -p \"$SAFEDIRECTORY\"");

$CONTAINERSIZE *= 1000;

if ($SIZETYPE eq "GB") {
    $CONTAINERSIZE *= 1000;
}

push(@commands, "dd if=/dev/urandom of=\"$CONTAINERFILE\" bs=1024 count=$CONTAINERSIZE");

push(@commands, "losetup /dev/loop0 \"$CONTAINERFILE\"");

push(@commands, "echo -n \"$PASSWORD\" | cryptsetup --hash sha512 --cipher twofish-cbc-plain --key-size 256 create secret_img /dev/loop0 --key-file=-");

push(@commands, "mke2fs -j /dev/mapper/secret_img");

push(@commands, "mount /dev/mapper/secret_img \"$SAFEDIRECTORY\"");

my $i;
for $i (@commands) {
    print "$i\n";
    system($i);
}

print "\nCreate mosa and umosa-files (y/n)? ";
checkForYes();

my @mosa = ("#!/bin/bash",
            "",
            "modprobe cryptoloop",
            "losetup /dev/loop0 \"$CONTAINERFILE\"",
            "cryptsetup --hash sha512 --cipher twofish-cbc-plain --key-size 256 create secret_img /dev/loop0", 
            "mount /dev/mapper/secret_img \"$SAFEDIRECTORY\"");

my @umosa = ("#!/bin/bash",
             "",
             "umount \"$SAFEDIRECTORY\"",
             "cryptsetup close /dev/mapper/secret_img",
             "losetup -d /dev/loop0");

writefile($MOSAFILENAME,  \@mosa);
writefile($UMOSAFILENAME, \@umosa);

print "\nDone.\n\n";

# -------------------------------------------------

=cut

# Deprecated shell-commands for even older Linux distributions:

# SuSE 8.1:
# modprobe loop_fish2
# dd if=/dev/urandom of=/home/def/cryptfile bs=1024 count=120000
# mkdir /home/user/safe 
# losetup -e twofish /dev/loop0 /home/def/cryptfile
# mke2fs /dev/loop0
# mount -t ext2 /dev/loop0 /home/user/safe 
# cat /home/user/system/sffile1 >> /etc/init.d/boot.local
# echo
# echo "Added the following line to /etc/init.d/boot.local:"
# echo "modprobe loop_fish2"
# cat /home/user/system/sffile2 >> /etc/fstab
# echo
# echo "Added the following line to /etc/fstab:" 
# echo "/home/user/cryptfile /home/user/safe ext2 loop,encryption=twofish,noauto,user 0 0"
# echo
# chown user.users /home/user/cryptfile
# chown -R user.users /home/user/safe 
# echo "Ready."

# Mandrake Linux:
# modprobe twofish
# modprobe cryptoloop
# dd if=/dev/urandom of=/home/user/cryptfile bs=1024 count=200000
# mkdir /home/user/safe 
# losetup -e twofish256 /dev/loop0 /home/user/cryptfile
# mke2fs /dev/loop0
# mount -t ext2 /dev/loop0 /home/user/safe 
# 
# File /etc/rc.d/rc.local:
# modprobe twofish
# modprobe cryptoloop
# /etc/fstab (see above)
