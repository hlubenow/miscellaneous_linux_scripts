       shufflemp3.pl - A shuffle-player for mp3-files (for Linux-terminals)

       shufflemp3.pl shuffles mp3-files found in and below the current working
       directory.

       shufflemp3.pl (Linux only) searches in and below the current working
       directory for files ending with ".mp3", ".MP3", ".Mp3" or ".mP3" and
       plays them as mp3s with the external command "mpg123" in random order,
       looping.

       It features direct key-input-control in Linux-terminal.

       You may be surprised, which mp3-files are found, when you start it in
       an unfamiliar directory.

       shufflemp3.pl starts just one instance of "mpg123" in remote-control-
       mode.

       By default, the directory is searched recursively, but you can play
       just the mp3-files inside the directory (but not below it), by starting
       the script with the "-dir"-option.

       Available keys are:

           n           Play next song.
           p           Play previous song.
           LEFT        Go backwards in a song.
           RIGHT       Go forward in a song.
           c           Play certain song.
           SPACE       Pause.
           h           Show help.
           q           Quit.

CAVEATS
       Unusual exits of the script may corrupt your current terminal-settings;
       just cancel your terminal with "ALT+F4" then and start a new one.

       The script tries to find everything that ends with ".mp3", ".MP3",
       ".Mp3" or ".mP3". It doesn't check, if the files found are really
       mp3-files. So don't use the script, if you have documents, that are not
       mp3-files but end with something like ".mp3" (see above) inside or
       below your current working directory.

PREREQUISITES
       This script requires the following modules:

       "Audio::Play::MPG123"

       "Term::ReadKey"

       "Cwd"

       "File::Find"

       "File::Basename"

       "List::Util"

       Also needed is the console-mp3-player "mpg321".

COPYRIGHT AND LICENSE
       shufflemp3.pl is Copyright (C) 2009-2012, hlubenow.

       This program is free software; you can redistribute it and/or modify it
       under the same terms as Perl 5.14.2.  For more details, see the full
       text of the licenses at

       <http://www.perlfoundation.org/artistic_license_1_0> and

       <http://www.gnu.org/licenses/gpl-2.0.html>.

       The full text of the licenses can also be found in the documents
       "perldoc perlgpl" and "perldoc perlartistic" of the official Perl
       5.14.2-distribution. In case of any contradictions, these
       'perldoc'-texts are decisive.

       THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
       WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
       MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. FOR MORE DETAILS,
       SEE THE FULL TEXTS OF THE LICENSES MENTIONED ABOVE.
