#### makecrypt.pl 1.0 - May Create an Encrypted Data Container on OpenSuSE Linux 13.1

On many Linux systems, it is possible to create a "data safe", that is a password secured, encrypted container file for sensible data.
I'm still happy with my 32bit PC, that is considered old by now, which uses OpenSuSE 13.1.
On this machine, I can setup such a container by going through a process which I have described [here](https://hlubenow.lima-city.de/suse131.html#30).

To automate this process, I wrote this Perl script `makecrypt.pl`.
It works on my (old) machine, but I can't guarantee, it also works on newer systems. It could be, that the required shell commands and options have changed in the meantime (`makecrypt.pl` uses system-calls to the commands described in [my article](https://hlubenow.lima-city.de/suse131.html#30)). Then the script won't work properly. As said, I have only tested it with OpenSuSE 13.1.

A result of the script should be:

- an encrypted container file of a given size (several MB or even GB),
- a directory, that can be mounted and umounted, in which the contents of the container file can be accessed,
- the bash-scripts `mosa_new` and `umosa_new` in the script's directory.

`mosa` is short for `mount safe`, `umosa` for `umount safe` respectively (These are just two abbreviations, I made up).
The scripts contain the shell commands, that are needed to mount, respectively umount the data safe (including the safe directory).
When executing `mosa_new`, you are asked for the safe's password on the command-line. This password was determined during safe creation by the script `makecrypt.pl`.

So the script `makecrypt.pl` needs some information:

- What will the filename of the container file be?
- Which directory will show the contents of the container file when mounted?
- What size will the container file have? 
- "MB" (megabytes) or "GB" (gigabytes)?
- What is the password to be used to access the safe?
- What shall the files for the `mosa` and `umosa` scripts be called?

This information is given to the script by editing the variable section at its beginning. If you execute the script without having edited it before, it will exit with an error. 
The variable section of the script looks like this (it shouldn't be too difficult to edit the variables according to your needs):

```
# Variable settings: These need to be edited by the user:

my $CONTAINERFILE      = "/home/user/newcryptfile";
my $SAFEDIRECTORY      = "/home/user/newsafe";
my $CONTAINERSIZE      = 2;
my $SIZETYPE           = "MB";
my $PASSWORD           = "test";
my $MOSAFILENAME       = "mosa_new";
my $UMOSAFILENAME      = "umosa_new";
```

Writing a container file of 1 GB or more may take a while. So sometimes patience is required.

When the script is finished, the safe's directory should be accessible, and there should be (only) a subdirectory called `lost+found` inside it. So right after creation the safe is open (!). You then can write other content into the directory. When you're done, leave the directory and run `umosa_new` to close it (closing the directory won't work, while you're still in it). After the directory was closed, the container file still holds the contents, but they cannot be accessed until the directory is mounted again by running `mosa_new`. But to successfully run `mosa_new`, the safe's password is required. That's how using the safe works.

So, the script `makecrypt.pl` is only run once to create the data safe. To open and close the safe afterwards, the scripts `mosa_new` and `umosa_new` are used.

The scripts `mosa_new` and `umosa_new` can also be renamed lateron if needed. It doesn't really matter, how they're called.

License of `makecrypt.pl` : GNU GPL, version 3 (or above). 
