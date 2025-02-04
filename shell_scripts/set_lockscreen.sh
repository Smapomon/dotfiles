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

i3lock -i $TMPBG & sleep 5

