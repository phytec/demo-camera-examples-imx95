#!/bin/sh

if [ -n "$1" ]; then
	FILENAME="$1"
else
	FILENAME=$(find . -name "*H.264_HD.mkv" -print -quit)
fi

if [ -z "$FILENAME" ]; then
	echo "Error: No H.264 encoded file found."
	exit 1
fi

if [ ! -r "$FILENAME" ]; then
	echo "Error: File ${FILENAME} not accessable."
	exit 1
fi

echo ""
echo "Playing ${FILENAME} with gstreamer, break with Ctrl-C"
echo "========================================================================="
echo ""

gst-launch-1.0 \
filesrc location="$FILENAME" ! \
matroskademux ! h264parse ! v4l2h264dec ! \
queue ! waylandsink sync=true
