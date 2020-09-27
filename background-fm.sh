#!/bin/bash
NAME=background-fm
if [ -z $HOME ] && ([ -z $XDG_DATA_HOME ] || [ -z $XDG_CACHE_HOME ]); then 
	echo You need to have either \$HOME environment variable set or both \$XDG_DATA_HOME and \$XDG_CACHE_HOME to use this program
	exit 1
fi
if [ -z $XDG_DATA_HOME ]; then
	XDG_DATA_HOME=$HOME/.local/share
fi
if [ -z $XDG_CACHE_HOME ]; then
	XDG_CACHE_HOME=$HOME/.cache
fi
DATA_DIR=$XDG_DATA_HOME/$NAME
CACHE_DIR=$XDG_CACHE_HOME/$NAME
if [ ! -d $DATA_DIR ]; then
	mkdir -p $DATA_DIR
fi
if [ ! -d $CACHE_DIR ]; then
	mkdir -p $CACHE_DIR
fi

APIKEYLOCATION=$DATA_DIR/apikey
if [ ! -e $APIKEYLOCATION ]; then
	echo Please place your last.fm apikey in $APIKEYLOCATION
	exit 1
fi
APIKEY=$(cat $APIKEYLOCATION)

ALBUM_COUNT=20
USERNAME=thebradad1111
URL="http://ws.audioscrobbler.com/2.0/?method=user.gettopalbums&user=${USERNAME}&api_key=${APIKEY}&period=1month&limit=20"
echo URL:$URL
IMAGE_URLS=$(curl $URL | grep '<image size="extralarge"' | sed -r 's/<\/?\w(\w|| )+(="\w+")?>//g' | sed 's/ //g')
declare -a FILE_NAMES
for IMAGE_URL in $IMAGE_URLS; do
	FILENAME=$(grep -Po '\w+\.\w+$' <<< $IMAGE_URL)
	if [ ! -e $FILENAME ]; then
		curl $IMAGE_URL -o $CACHE_DIR/$FILENAME
	fi
done
