#!/usr/bin/env bash
if [ -z $HOME ] && ([ -z $XDG_DATA_HOME ] || [ -z $XDG_CACHE_HOME ]); then 
	echo You need to have either \$HOME environment variable set or both \$XDG_DATA_HOME and \$XDG_CACHE_HOME to use this program
	exit 1
fi
if [ -z $XDG_DATA_HOME ]; then
	XDG_DATA_HOME="$HOME/.local/share"
fi
if [ -z $XDG_CACHE_HOME ]; then
	XDG_CACHE_HOME="$HOME/.cache"
fi

if [ -f "$XDG_CACHE_HOME/background-media/.playing" ]; then
    IMAGE="$XDG_CACHE_HOME/background-media/result.png"
    FEH_OPTIONS="--bg-fill"
else
    IMAGE="$XDG_CACHE_HOME/background-fm/out.png"
    FEH_OPTIONS="--bg-tile"
fi

feh $FEH_OPTIONS $IMAGE
