#### startlxterminal.pl 1.0

When starting "lxterminal" on LXDE, it often happens somehow, that the new terminal-window is just opened in the background and doesn't get focus, which is annoying.

This script runs "lxterminal", giving the new window a title like "Terminal_1", "Terminal_2" and so on. Then it waits a second, and after that gives the new window focus by calling the program "wmctrl".

License: GNU GPL 3 (or above)
