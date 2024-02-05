#!/bin/bash

#remove any previous screenshots
rm /tmp/screensho*.png

# get a screenshot and blur it
TMPBG=/tmp/screenshot.png
scrot $TMPBG
convert $TMPBG -blur 0x6 $TMPBG
convert $TMPBG \
	-pointsize 25 -gravity North -background Orange -splice 0x32 -annotate -300+2 "System Locked..." \
	$TMPBG

# alternative way to convert blur/pixelation
#scrot $TMPBG && convert $TMPBG -scale 5% -scale 2000% -draw "fill black fill-opacity 0.4" $TMPBG

# use this when dunst problem fixed https://github.com/betterlockscreen/betterlockscreen/issues/284
#betterlockscreen -l dim

i3lock -i $TMPBG \
	& sleep 5 && xset dpms force off

