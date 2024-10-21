# Copy2AmiClip
Copy clipboard on Mac, Windows or Linux to your Amiga over network.
## About and Why
When I started to revive my Amiga, I often had the situation that I researched things on my modern computer (a Mac in my case) that I would have liked to transfer quickly to my Amiga. Things like code snippets, URLs, ....

Always writing them to a file and transferring via FTP or even typing was tedious and error-prone. So I thought a cross-device copy and paste would be nice. Just like I knew it from my Apple devices. That's how Copy2AmiClip was born. At first only as an Amiga-DOS and a Shell script, now as an AREXX script on the Amiga side and a Python Script on the modern side. Actually, it is designed and tested on MacOS. But I also test it on Linux (Debian and Fedora). It should work on Windows too but still untested.
## Tech
You may wonder why the text copied over the network is Base64 encoded. This is because I had many problems when the text included special characters. So the easiest way to work around this was to encode it this way.
## Requirements
- On the Amiga side, you need a working TCP network. I use the RoadShow Stack. Miami or Aminet should work too.
- You need some additional ARexx libs from Aminet. RexxTricks Lib: http://aminet.net/package/util/rexx/RexxTricks_386.lha and RXSocket Lib:   http://aminet.net/package/comm/tcp/rxsocket.
## Installation
### Amiga
- Copy the rxsocket and rxtricks libs to libs:.
- Copy copy2amigaclip.rexx to s:.
- Put this in your s:user-startup or run it in a shell.
#### s:startup
    run <>nil: rx s:copy2amigaclip.rexx > nil:
### Mac
- Install Python 3 on your Mac. I prefer Homebrew for that.
- Copy copy2amiclip.py somewhere on your Mac. I use my home directory.
- Set the IP, Port and Codepage to suit your needs.
- Then use a shortcut tool like Keyboard Cowboy to set up a shortcut to start the script whenever you want to send your clipboard to your Amiga.

![alt text](image.png)
### Linux
- Install some packages.
#### Debian based Distros

    apt install xclip
    apt install xsel
    apt install wl-clipboard
    apt install python3-pyperclip

#### Fedora based Distros

    dfn install xclip
    dfn install xsel
    dfn install wl-clipboard
    dfn install python-pyperclip

- Copy copy2amiclip.py somewhere on your Linux. I use my home directory.
- Set the IP, Port and Codepage to suit your needs.
- Then use a shortcut tool and set up a shortcut to start the script whenever you want to send your clipboard to your Amiga.

### Windows
ToDo. I have not tested it yet! May run, may not but you have to install Python3 and the PyPerClip module.
## Usage
Simple! After copy2amiclip.rexx is running on your Amiga, just press the keyboard shortcut you have configured. Your keyboard tool should then start the script. To test it simply run the script by hand.
## Debug
On the client side, there should be a logfile in /tmp and in t: on the Amiga. If you want to quit the process on the Amiga send a 'quit' (without quotes).
## ToDo
- Writing the code for Windows and Linux.
- Ability to end the task on Amiga.
