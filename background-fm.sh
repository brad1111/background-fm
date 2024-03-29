#!/usr/bin/env bash

#Setup directories and stuff
NAME=background-fm
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
DATA_DIR="$XDG_DATA_HOME/$NAME"
CACHE_DIR="$XDG_CACHE_HOME/$NAME"
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

#Get number of albums etc
X=6
Y=4
let ALBUM_COUNT=$X*$Y
USERNAME=thebradad1111
URL="http://ws.audioscrobbler.com/2.0/?method=user.gettopalbums&user=${USERNAME}&api_key=${APIKEY}&period=1month&limit=${ALBUM_COUNT}"
#Get image urls from XML
IMAGE_URLS=$(curl $URL | grep '<image size="extralarge"' | sed -r 's/<\/?\w(\w|| )+(="\w+")?>//g' | sed 's/ //g')
#Store file locations so we can keep order of albums
declare -a FILE_LOCATIONS
for IMAGE_URL in $IMAGE_URLS; do
	FILENAME=$(grep -Po '\w+\.\w+$' <<< $IMAGE_URL)
	FILE_LOCATION=$CACHE_DIR/$FILENAME
	FILE_LOCATIONS+=("${FILE_LOCATION}")
	if [ ! -e $FILE_LOCATION ]; then
		curl $IMAGE_URL -o $FILE_LOCATION 
	fi
done

OUTIMG=$CACHE_DIR/out.png
if [ -e $OUTIMG ]; then
	rm $OUTIMG
fi
montage -tile ${X}x${Y} -geometry +0+0 ${FILE_LOCATIONS[*]} $OUTIMG
