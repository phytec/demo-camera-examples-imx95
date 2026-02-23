#!/bin/sh

# Only evaluated if phyCAM-L camera connected.
PHYCAM_L_PORT=0

source /usr/share/phytec-gstreamer-examples/tools/func.sh

detect_sensor_type "ISP" "CSI1" $PHYCAM_L_PORT
select_format
select_mode "Full"

HOST_IP="192.168.3.10"
UDP_PORT="5200"

echo "================================================================================="
echo "Starting VPU encoded stream from ${CAM_PHYCAM_NAME} on ${INTERFACE} via ${PROC} using Gstreamer"
echo "Configured Sensor Mode: ${CAM_MODENAME}"
echo "Capturing ${CAP_WIDTH}x${CAP_HEIGHT} with ${CAP_FMT} from ${LIBCAM_NAME},"
echo "converting it to a H264 stream and streaming it via Network to ${HOST_IP}:${UDP_PORT}"
echo ""
echo "Note: Make sure to configure the correct HOST_IP in this script and the"
echo "correct Target device IP in VLC_Network_Stream.sdp"
echo "================================================================================="

set_mode_libcamera
set_controls

SOURCE="libcamerasrc camera-name=${LIBCAM_NAME} ${LIBCAM_STREAM_ROLE}"
RATE="videorate ! $(echo ${GST_FMT} | cut -d',' -f1),framerate=30/1"
ENCODING="queue ! v4l2h264enc ! rtph264pay"
SINK="udpsink host=${HOST_IP} port=${UDP_PORT} sync=false"

echo "  LIBCAMERA_PIPELINES_MATCH_LIST='nxp/neo' gst-launch-1.0 ${SOURCE} ! \\"
echo "    ${GST_FMT} ! \\"
echo "    ${RATE} ! \\"
echo "    ${ENCODING} ! \\"
echo "    ${SINK}"
echo ""

PIPELINE="${SOURCE} ! ${GST_FMT} ! ${RATE} ! ${ENCODING} ! ${SINK}"

LIBCAMERA_PIPELINES_MATCH_LIST='nxp/neo' gst-launch-1.0 ${PIPELINE}
