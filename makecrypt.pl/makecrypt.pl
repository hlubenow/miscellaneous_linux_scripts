#!/usr/bin/perl

use warnings;
use strict;

use Cwd;

=begin comment

    makecrypt.pl 1.1 - May create an encypted data container
                       on certain Linux distributions.
                       Works for me on OpenSuSE Linux 13.1 (32bit).

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

sub getOptions {
    my @o = qw(containerfile safedirectory containersize sizetype password mosafilename umosafilename);
    my @o2 = qw(cf sd cs st pw mf uf);
    my %options;
    my ($i, $u);
    for $i (@o) {
        $options{$i} = "";
    }
    $options{mosafilename}  = "mosa_new";
    $options{umosafilename} = "umosa_new";
    $options{sizetype}      = "mb";
    $options{nomosafiles}   = 0;
    for $i (@ARGV) {
        if ($i eq "-h" || $i eq "--help") {
            printUsageMessage(1);
            exit 0;
        }
        if ($i eq "--nomosafiles" || $i eq "-nm") {
            $options{nomosafiles} = 1;
        }
    }
    for $i (0 .. $#ARGV - 1) {
        for $u (0 .. $#o) {
            if ("--$o[$u]" eq $ARGV[$i] || "-$o2[$u]" eq $ARGV[$i]) {
                $options{$o[$u]} = $ARGV[$i + 1];
                last;
            }
        }
    }
    for $i (@o) {
        if ($options{$i} eq "") {
            print "Error: Option '--$i' not set.\n\n";
            printUsageMessage(0);
            exit 1;
        }
    }
    if ($options{containersize} =~ /\D/) {
        print "\nError: Containersize should be a number, not '$options{containersize}'.\n\n";
        exit 1;
    }
    if ($options{containersize} < 1 || $options{containersize} > 999) {
        print "Error: Containersize should be a number between 1 and 999. If you want more than 999 MB, use '--sizetype gb'.\n\n";
        exit 1;
    }
    $options{sizetype} = lc($options{sizetype});
    if ($options{sizetype} ne "mb" && $options{sizetype} ne "gb") {
        print "Error: Invalid sizetype.\n\n";
        exit 1;
    }
    $options{mosafilename}  = getcwd() . "/$options{mosafilename}";
    $options{umosafilename} = getcwd() . "/$options{umosafilename}";
    return %options;
}

sub printUsageMessage {
    my $defs = shift;
    print "Usage:\n\n";
    print "makecrypt.pl --containerfile/-cf --safedirectory/-sd -containersize/-cs --password/-pw [--sizetype/-st] [--mosafilename/-mf] [--umosafilename/-uf] [--nomosafiles/-nm] [--help/-h]\n\n";
    if ($defs) {
        print "Defaults are:\n";
        print "--sizetype:      mb\n";
        print "--mosafilename:  mosa_new\n";
        print "--umosafilename: umosa_new\n";
        print "--nomosafiles:   Option not set.\n\n";
    }
    print "Example:\n\n";
    print "makecrypt.pl --containerfile /home/user/newcryptfile --safedirectory /home/user/newsafe --containersize 2 --sizetype mb --password test\n\n"; 
}

sub checkShellCommands {
    my @shcommands = qw(modprobe mkdir dd losetup cryptsetup mke2fs mount);
    my $i;
    my @t;
    for $i (@shcommands) {
        @t = `which $i 2>/dev/null`;
        if ($#t < 0) {
            print "Error: Required shell-command '$i' not found. Further installation needed. Nothing done.\n\n";
            exit 1;
        }
    }
}

sub checkFileExists {
    my $fname = shift;
    if (-e $fname) {
        print "'$fname' already exists. Nothing done.\n\n";
        exit 1;
    }
}

sub checkForYes {
    my $inp = <STDIN>;
    chomp($inp);
    print "\n";
    if ($inp eq "y") {
        return 1;
    } else {
        return 0;
    }
}

sub writefile {
    my $fname   = shift;
    my @content = @{ shift() };
    my $inp;
    if (-e $fname) {
        print "File '$fname' already exists. Do you want to overwrite it (y/n)? ";
        if (checkForYes() == 0) {
            print "File '$fname' not written.\n";
            return;
        }
    }
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

checkShellCommands();

my %options = getOptions();

checkFileExists($options{containerfile});
checkFileExists($options{safedirectory});

print "Settings:\n\n";
print "Container-file:\t$options{containerfile}\n";
print "Safe directory:\t$options{safedirectory}\n";
print "Container size:\t$options{containersize} " . uc($options{sizetype}) . "\n";
print "Password:\t$options{password}\n";
if ($options{nomosafiles} == 0) {
    print "mosa filename:\t$options{mosafilename}\n";
    print "umosa filename:\t$options{umosafilename}\n";
}
print "\n";

print "Proceed with these settings (y/n)? ";
if (checkForYes() == 0) {
    print "Bye.\n\n";
    exit 0;
}

my @commands = ("modprobe cryptoloop");
push(@commands, "mkdir -p \"$options{safedirectory}\"");

$options{containersize} *= 1000;
if ($options{sizetype} eq "gb") {
    $options{containersize} *= 1000;
}

push(@commands, "dd if=/dev/urandom of=\"$options{containerfile}\" bs=1024 count=$options{containersize}");
push(@commands, "losetup /dev/loop0 \"$options{containerfile}\"");
push(@commands, "echo -n \"$options{password}\" | cryptsetup --hash sha512 --cipher twofish-cbc-plain --key-size 256 create secret_img /dev/loop0 --key-file=-");
push(@commands, "mke2fs -j /dev/mapper/secret_img");
push(@commands, "mount /dev/mapper/secret_img \"$options{safedirectory}\"");
my $i;
for $i (@commands) {
    print "$i\n";
    system($i);
}

if ($options{nomosafiles} == 0) {
    my @mosa = ("#!/bin/bash",
                "",
                "modprobe cryptoloop",
                "losetup /dev/loop0 \"$options{containerfile}\"",
                "cryptsetup --hash sha512 --cipher twofish-cbc-plain --key-size 256 create secret_img /dev/loop0", 
                "mount /dev/mapper/secret_img \"$options{safedirectory}\"");
    my @umosa = ("#!/bin/bash",
                 "",
                 "umount \"$options{safedirectory}\"",
                 "cryptsetup close /dev/mapper/secret_img",
                 "losetup -d /dev/loop0");
    writefile($options{mosafilename},  \@mosa);
    writefile($options{umosafilename}, \@umosa);
}

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
# echo "/home/def/cryptfile /home/user/safe ext2 loop,encryption=twofish,noauto,user 0 0"
# echo
# chown def.users /home/def/cryptfile
# chown -R def.users /home/user/safe 
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

