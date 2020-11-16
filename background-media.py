#!/usr/bin/env python3
import gi
gi.require_version('Playerctl', '2.0')
from gi.repository import GLib, Playerctl
import subprocess
import re

player = Playerctl.Player()

playing = False

cachedir = GLib.get_user_special_dir(GLib.USER

def on_metadata(player, metadata):
    print(playing)
    print(metadata)
   
    artUrl = None
    trackId = None
    if 'mpris:artUrl' and 'mpris:trackid' in metadata.keys():
        artUrl = metadata["mpris:artUrl"]
        trackId = metadata["mpris:trackid"]
    
    if isinstance(trackId, str) and isinstance(artUrl, str) and trackId.startswith('spotify'):
        artUrl = re.sub("https?:\\/\\/open.spotify.com\\/image\\/", "https://i.scdn.co/image", artUrl) 
    print(artUrl)
    subprocess.run(["feh","--bg-max","/home/bradley/.cache/background-fm/0ae77c1bb44c6b3aba4fb0d83551493c.jpg"])
    #if 'mpris:artUrl' in metadata.keys():
     #   print(metadata['mpris:artUrl'])

def on_play(player,status):
    global playing
    playing = True

def on_pause(player,status):
    global playing
    playing = False

player.connect('metadata', on_metadata)
player.connect('playback-status::playing', on_play)
player.connect('playback-status::paused', on_pause)

main = GLib.MainLoop()
main.run()
