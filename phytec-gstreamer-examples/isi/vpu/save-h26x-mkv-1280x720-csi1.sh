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
echo "converting it to a H264 stream and saving it as"
echo "${CAM_NAME}_${CAM_COLOR}_H.26x_HD.mkv"
echo "================================================================================="

echo " Choose the Encoder to use"
echo " ========================="
echo " 1 = H.264 (IMX VPU-based AVC/H264 video encoder)"
echo " 2 = H.265 (IMX VPU-based HEVC/H265 video encoder)"
read ENCODER_TYP_NUMBER
echo " Your selection = $ENCODER_TYP_NUMBER"
case $ENCODER_TYP_NUMBER in
  "1") ENCODER_TYP="H.264"; ENCODING="queue ! v4l2h264enc ! h264parse ! matroskamux";;
  "2") ENCODER_TYP="H.265"; ENCODING="queue ! v4l2h265enc ! h265parse ! matroskamux";;
  *) ENCODING="queue ! v4l2h264enc ! rtph264pay";;
esac

SOURCE="v4l2src device=${CAP_DEVICE}"
SINK="filesink location=${CAM_NAME}_${CAM_COLOR}_${ENCODER_TYP}_HD.mkv"

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
