# streamlink_mod
auto-renew streamlink session if there is any interruption

==============================
    Installation Instructions
==============================

clone this repo to your scripts directory

    $ git clone https://github.com/Herbling101/streamlink_mod.git
    
open a shell in the directory which contains setup.py

then enter:

    $ pip install .

then type:
	
     $streamlink-mod

and hit enter for usage instructions. 

example:

	$streamlink-mod https://www.youtube.com/watch?v=gCNeDWCI0vo output.mp4

this should start a new streamlink instance on the url and write to "output_1.mp4" in the shell's current working directory

the streamlink operation is now wrapped as a subprocess within the streamlink-mod.py script, which will check if the operation is occurring once every second. If the stream is interrupted for any reason, the script should start a new stream with the same url and a new filename_x (output_2.mp4, output_3.mp4, ...)


    Reload your bash terminal.

Usage:
    
    $ streamlink-mod start "URL" "FILENAME.mp4" | streamlink-mod stop
