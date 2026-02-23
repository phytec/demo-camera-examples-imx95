#!/bin/sh

# Only evaluated if phyCAM-L camera connected.
PHYCAM_L_PORT=0

source /usr/share/phytec-gstreamer-examples/tools/func.sh

detect_sensor_type "ISI" "CSI1" $PHYCAM_L_PORT
select_format
select_mode "HD"

set_mode
set_controls

echo "================================================================================="
echo "Starting gstreamer with ${CAM_FMT} Source on ${INTERFACE} via ${PROC}"
echo "Configured Sensor Mode: ${CAM_MODENAME}"
echo "Capturing ${CAP_WIDTH}x${CAP_HEIGHT} with ${CAP_FMT} from ${CAP_DEVICE},"
echo "converting it to a H264 stream and saving it as ${CAM_NAME}_${CAM_COLOR}_HD.mkv"
echo "================================================================================="

SOURCE="v4l2src device=${CAP_DEVICE}"
ENCODING="queue ! v4l2h264enc ! h264parse ! matroskamux"
SINK="filesink location=${CAM_NAME}_${CAM_COLOR}_HD.mkv"

echo "  gst-launch-1.0 ${SOURCE} ! \\"
echo "    ${GST_FMT} ! \\"
if [ -n "${GST_CONV}" ] ; then
	echo "    ${GST_CONV} ! \\"
fi
echo "    ${ENCODING} ! \\"
echo "    ${SINK}"
echo ""

PIPELINE="${SOURCE} ! ${GST_FMT}"
if [ -n "${GST_CONV}" ] ; then
	PIPELINE="${PIPELINE} ! ${GST_CONV}"
fi
PIPELINE="${PIPELINE} ! ${ENCODING} ! ${SINK}"

gst-launch-1.0 ${PIPELINE}
