#!/usr/bin/env python3
import gi
gi.require_version('Playerctl', '2.0')
from gi.repository import GLib, Playerctl
import subprocess
import re
from urllib import request, parse
import os.path
import json
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
from xdg import xdg_cache_home, xdg_config_home

player = Playerctl.Player()
playing = False
previousAlbumArt = None #Used to not reblur if you're listening to an album

cachedir = xdg_cache_home().joinpath("background-media")
configdir = xdg_config_home().joinpath("background-media")

def on_metadata(player, metadata):
   #print(playing)
   #print(metadata)
    
    if not playing:
        return
    global previousAlbumArt 
    
    artUrl = None
    trackId = None
    if 'mpris:artUrl' and 'mpris:trackid' in metadata.keys():
        artUrl = metadata["mpris:artUrl"]
        trackId = metadata["mpris:trackid"]
        try:
            artUrl =sp.track(trackId)["album"]["images"][0]["url"]
        except:
            print("couldn't find artUrl from api, using mpris")
        #print(sp.track(trackId)["images"])
    else:
        return
    
    #print(imageLocation)


    if isinstance(trackId, str) and isinstance(artUrl, str) and trackId.startswith('spotify'):
        artUrl = re.sub("https?:\\/\\/open.spotify.com\\/image\\/", "https://i.scdn.co/image/", artUrl) 
    fileName = parse.urlparse(artUrl).path.split('/')[-1]
    imageLocation = cachedir.joinpath(fileName)
    resultImage = cachedir.joinpath("result.png")
    print(resultImage)
    if not os.path.isfile(imageLocation):
       print("Downloading:" + artUrl)
       request.urlretrieve(artUrl, imageLocation)
    # print(artUrl)
# convert ab67616d0000b27322fcfdc99b8aa0dbe167989d \( -clone 0 -blur 0x9 -resize 1920x1200\! \) \( -clone 0 \) -delete 0 -gravity center -compose over -composite result.png # to blur image
    if imageLocation != previousAlbumArt:
        print("blurring image")
        subprocess.run(["convert", imageLocation, "(", "-clone", "0", "-blur", "0x9", "-resize", "1920x1200!", ")", "(", "-clone", "0", ")", "-delete", "0", "-gravity", "center", "-compose", "over", "-composite", resultImage])
    subprocess.run(["feh","--bg-max",resultImage])
    previousAlbumArt = imageLocation
    #if 'mpris:artUrl' in metadata.keys():
     #   print(metadata['mpris:artUrl'])

def on_play(player,status):
    global playing
    playing = True

def on_pause(player,status):
    global playing
    playing = False
    subprocess.run(["feh","--bg-tile",cachedir.joinpath("../background-fm/out.png")])

player.connect('metadata', on_metadata)
player.connect('playback-status::playing', on_play)
player.connect('playback-status::paused', on_pause)

# spotify auth
spotifyConfig = json.loads(open(configdir.joinpath("spotify_config.json"), 'r').read())
print(spotifyConfig)
sp = spotipy.Spotify(auth_manager=SpotifyClientCredentials(client_id=spotifyConfig["id"],client_secret=spotifyConfig["secret"]))

    
main = GLib.MainLoop()
main.run()
