srt\_sync
=========

This is a simple program to update the subtitles (srt) time references. It
allows you to resync a miss synced subtitles srt file through a simple linear
function.

Install
-------

### Pre-requisite

This script needs only ocaml installed.

### Installation

Simply move the script to your favorite location for your executables :
	/usr/local/bin/
	~/bin/
	...

Usage
-----

The script will update all the time inserted in the subtitles (srt) file
regarding a simple linear function defined with :

	new_time = (a . old_time) + b

So you can set the 'a' parameter with --a command line option wich takes a float
parameter. The 'b' parameter is set with the --b command line option and takes
also a float.

Regarding file encoding. Currently it is not detected by the script, so if you
have a unix-like file (only LF, Mac OS X files are like this too) use the
--unix option to prevent the program to write the CRLF at the end of the lines
it will edit.

### Example

To re-sync for a 24 fps video, subtitles set for 25 fps video, use a = 24/25 =
0.96 :

	srt_sync.ml --a 0.96

To re-sync for a 30 fps video, subtitles set for a 25 fps video, use a = 30/25
= 1.2:

	srt_sync.ml --a 1.2

As an advise, first set the 'a' parameter, then the 'b'.
