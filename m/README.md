
### m - Play multimedia-file(s)

2026-02: News: Updated the old version of 2021 to version 1.3, mainly of 2024.
It's possible to just run `m` now (without asterisk), and it tries to play everything it finds in the current working directory.
Passing a number to it, makes it try to play that and the following files: That is, if `14` is passed, and it finds at least `14.mp4`, it tries to play `14.mp4`, `15.mp4` and so on.

`m` is a little Perl-script I use, to play media files of different types on the Linux console.

When I want to play a video clip, I don't want to mess with cryptic commands
such as
```
mplayer -fs af volnorm [file]
```
and so on. I also don't want to think about, which program to use. I just throw every filename at `m`, and if it
recognizes a media file, it plays it. That's very convenient.
I often just use `m`, for example.

`m` is configured with the player programs I use, such as
`mplayer` (movies), `mpg321` (mp3s), `xmp` (tracker-mods) and so on.
If you want other programs, you'd have to edit the script.

To check out certain files, `m` sometimes calls the Linux `file` command.

License: GNU GPL 3 (or above)
