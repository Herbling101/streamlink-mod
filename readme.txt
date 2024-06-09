$ pip install psutil
$ pip install streamlink

Manual steps:

1. 
    edit line 28 of streamlink-mod.bashrc: [python your/path/here/streamlink-mod.py "$url" "$filename" &] and place the correct filepath to your streamlink-mod.py

2. 
    copy-paste contents of streamlink-mod.bashrc at the end of your bash.bashrc file in the default path [C:\Program Files\Git\etc\bash.bashrc].
    
    [etc - Shortcut.lnk] should take you there.
    
    save the file. 
    
    Reload your bash terminal.

Usage:
    $ streamlink-mod start "URL" "FILENAME.mp4" | streamlink-mod stop