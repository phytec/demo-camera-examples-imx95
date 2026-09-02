#!/bin/sh

# Only evaluated if phyCAM-L camera connected.
PHYCAM_L_PORT=0

source /usr/share/phytec-gstreamer-examples/tools/func.sh

detect_sensor_type "ISI" "CSI2" $PHYCAM_L_PORT
select_format
select_mode "HD"

HOST_IP="192.168.3.10"
UDP_PORT="5200"

echo "================================================================================="
echo "Starting VPU encoded stream from ${CAM_PHYCAM_NAME} on ${INTERFACE} via ${PROC}"
echo "using Gstreamer."
echo "Configured Sensor Mode: ${CAM_MODENAME}"
echo "Capturing ${CAP_WIDTH}x${CAP_HEIGHT} with ${CAP_FMT} from ${CAP_DEVICE},"
echo "converting it to a H264/H265 stream and streaming it via Network to"
echo "${HOST_IP}:${UDP_PORT}"
echo ""
echo "Note: Make sure to configure the correct HOST_IP in this script and the"
echo "correct Target device IP in VLC_Network_Stream.sdp"
echo "================================================================================="

echo " Choose the Encoder to use"
echo " ========================="
echo " 1 = H.264 (IMX VPU-based AVC/H264 video encoder)"
echo " 2 = H.265 (IMX VPU-based HEVC/H265 video encoder)"
read ENCODER_TYP_NUMBER
echo " Your selection = $ENCODER_TYP_NUMBER"
case $ENCODER_TYP_NUMBER in
  "1") ENCODING="queue ! v4l2h264enc ! rtph264pay";;
  "2") ENCODING="queue ! v4l2h265enc ! rtph265pay";;
  *) ENCODING="queue ! v4l2h264enc ! rtph264pay";;
esac

set_mode
set_controls

SOURCE="v4l2src device=${CAP_DEVICE}"
RATE="videorate ! $(echo ${GST_FMT} | cut -d',' -f1),framerate=30/1"
SINK="udpsink host=${HOST_IP} port=${UDP_PORT} sync=false"

echo "  gst-launch-1.0 ${SOURCE} ! \\"
echo "    ${GST_FMT} ! \\"
echo "    ${RATE} ! \\"
if [ -n "${GST_CONV}" ] ; then
	echo "    ${GST_CONV} ! \\"
fi
echo "    ${ENCODING} ! \\"
echo "    ${SINK}"
echo ""

PIPELINE="${SOURCE} ! ${GST_FMT} ! ${RATE}"
if [ -n "${GST_CONV}" ] ; then
	PIPELINE="${PIPELINE} ! ${GST_CONV}"
fi
PIPELINE="${PIPELINE} ! ${ENCODING} ! ${SINK}"

gst-launch-1.0 ${PIPELINE}
