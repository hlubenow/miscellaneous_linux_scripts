#### makecrypt.pl 1.2 - May Create an Encrypted Data Container on OpenSuSE Leap 15.5, Leap 15.4 (and on OpenSuSE 13.1)

On many Linux systems, it is possible to create a "data safe", that is a password secured, encrypted container file for sensible data.

On my 32bit PC, which uses OpenSuSE 13.1, I can setup such a container by going through a process which I have described [here](https://hlubenow.lima-city.de/suse131.html#30).
To automate this process, I wrote this Perl script `makecrypt.pl` on the old computer.
But as I just found out, the script also works on the more recent OpenSuSE Leap 15.4 (64 bit). The required shell commands are still available on the newer system, and options haven't changed in the meantime.

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

Here's an example, how the script can be called (as root) (for a container of just 2 megabytes):

```
makecrypt.pl --containerfile /home/user/newcryptfile --safedirectory /home/user/newsafe --containersize 2 --sizetype mb --password test
```

Writing a container file of 1 GB or more may take a while. So sometimes patience is required.

When the script is finished, the safe's directory should be accessible, and there should be (only) a subdirectory called `lost+found` inside it. So right after creation the safe is open (!). You then can write other content into the directory. When you're done, leave the directory and run `umosa_new` to close it (closing the directory won't work, while you're still in it). After the directory was closed, the container file still holds the contents, but they cannot be accessed until the directory is mounted again by running `mosa_new`. But to successfully run `mosa_new`, the safe's password is required. That's how using the safe works.

So, the script `makecrypt.pl` is only run once to create the data safe. To open and close the safe afterwards, the scripts `mosa_new` and `umosa_new` are used.

The scripts `mosa_new` and `umosa_new` can also be renamed lateron if needed. It doesn't really matter, what they're called.

Version 1.2: Since OpenSuSE Leap 15.5, the kernel module `cryptoloop` is no longer supported. The command `lsmod | grep crypto` shows, that a module called `cryptd` is active instead. Anyway, on this distribution the script just works without the line `modprobe cryptoloop`. So I commented it out.

License of `makecrypt.pl` : GNU GPL, version 3 (or above). 
