#### makecrypt.pl 1.1 - May Create an Encrypted Data Container on OpenSuSE Linux 13.1

On many Linux systems, it is possible to create a "data safe", that is a password secured, encrypted container file for sensible data.
I'm still happy with my 32bit PC, that is considered old by now, which uses OpenSuSE 13.1.
On this machine, I can setup such a container by going through a process which I have described [here](https://hlubenow.lima-city.de/suse131.html#30).

To automate this process, I wrote this Perl script `makecrypt.pl`.
It works on my (old) machine, but I can't guarantee, it works on newer systems. It could be, that the required shell commands and options have changed in the meantime. Then the script won't work properly. As said, I have only tested it on OpenSuSE 13.1.

`makecrypt.pl` uses system-calls to the shell commands described in [my article](https://hlubenow.lima-city.de/suse131.html#30). Maybe it would be a good idea to go through the article first and try to setup a data safe by hand (checking if all necessary shell commands are available), before trying to do it by script.

The result of running `makecrypt.pl` should be:

- an encrypted container file of a given size (several megabytes or even gigabytes),
- a directory, that can be mounted and umounted, in which the contents of the container file can be accessed,
- the bash-scripts `mosa_new` and `umosa_new` in the script's directory.

`mosa` is short for `mount safe`, `umosa` for `umount safe` respectively (These are just two abbreviations, I made up).
The scripts contain the shell commands, that are needed to mount, respectively umount the data safe (including the safe directory).
When executing `mosa_new`, you are asked for the safe's password on the command-line. This password was determined during safe creation by the script `makecrypt.pl`.

So the script `makecrypt.pl` needs some information, that has to be passed as options on the command-line:

- What will the filename of the container file be? Option "--containerfile" or "-cf".
- To which directory will the contents of the container file be mounted? Option "--safedirectory" or "-sd".
- What size will the container file have? Option "--containersize" or "-cs". The value is a number between 1 and 999. The meaning of this number (megabytes or gigabytes) depends on the "--sizetype"-option (default: megabytes).
- What is the password to be used to access the safe? Option "--password" or "-pw".

Passing values for these options is required. Passing other values is optional, because default values are set for them:

- "mb" (megabytes) or "gb" (gigabytes) for "--containersize"? Option "--sizetype" or "-st". Default: "mb".
- What shall the files for the `mosa` and `umosa` scripts be called? Options "--mosafilename" or "-mf", and "--umosafilename" or "-uf". Default values: "mosa_new" and "umosa_new".
- If you don't want to write the `mosa` and `umosa` scripts, use the option "--nomosafiles" or "-nm".

Writing a container file of 1 GB or more may take a while. So sometimes patience is required.

When the script is finished, the safe's directory should be accessible, and there should be (only) a subdirectory called `lost+found` inside it. So right after creation the safe is open (!). You then can write other content into the directory. When you're done, leave the directory and run `umosa_new` to close it (closing the directory won't work, while you're still in it). After the directory was closed, the container file still holds the contents, but they cannot be accessed until the directory is mounted again by running `mosa_new`. But to successfully run `mosa_new`, the safe's password is required. That's how using the safe works.

So, the script `makecrypt.pl` is only run once to create the data safe. To open and close the safe afterwards, the scripts `mosa_new` and `umosa_new` are used.

The scripts `mosa_new` and `umosa_new` can also be renamed lateron if needed. It doesn't really matter, what they're called.

License of `makecrypt.pl` : GNU GPL, version 3 (or above). 
