#!/bin/sh

# Only evaluated if phyCAM-L camera connected.
PHYCAM_L_PORT=0

source /usr/share/phytec-gstreamer-examples/tools/func.sh

detect_sensor_type "ISP" "CSI1" $PHYCAM_L_PORT
select_format
select_mode "Full"

echo "================================================================================="
echo "Starting gstreamer with ${CAM_FMT} Source on ${INTERFACE} via ${PROC}"
echo "Configured Sensor Mode: ${CAM_MODENAME}"
echo "Capturing ${CAP_WIDTH}x${CAP_HEIGHT} with ${CAP_FMT} from ${LIBCAM_NAME},"
echo "converting it to a H264 stream and saving it as ${CAM_NAME}_${CAM_COLOR}_FULL.mkv"
echo "================================================================================="

set_mode_libcamera
set_controls

SOURCE="libcamerasrc camera-name=${LIBCAM_NAME} ${LIBCAM_STREAM_ROLE}"
ENCODING="videoconvert ! queue ! v4l2h264enc ! h264parse ! matroskamux"
SINK="filesink location=${CAM_NAME}_${CAM_COLOR}_FULL.mkv"

echo "  LIBCAMERA_PIPELINES_MATCH_LIST='nxp/neo' gst-launch-1.0 ${SOURCE} ! \\"
echo "    ${GST_FMT} ! \\"
echo "    ${ENCODING} ! \\"
echo "    ${SINK}"
echo ""

PIPELINE="${SOURCE} ! ${GST_FMT} ! ${ENCODING} ! ${SINK}"

LIBCAMERA_PIPELINES_MATCH_LIST='nxp/neo' gst-launch-1.0 ${PIPELINE}
