#!/bin/sh

# Only evaluated if phyCAM-L camera connected.
PHYCAM_L_PORT=0

source /usr/share/phytec-gstreamer-examples/tools/func.sh

detect_sensor_type "ISP" "CSI2" $PHYCAM_L_PORT
select_format
select_mode "Full"

echo "================================================================================="
echo "Starting gstreamer with ${CAM_FMT} Source on ${INTERFACE} via ${PROC}"
echo "Configured Sensor Mode: ${CAM_MODENAME}"
echo "Capturing ${CAP_WIDTH}x${CAP_HEIGHT} with ${CAP_FMT} from ${LIBCAM_NAME}"
echo "================================================================================="

set_mode_libcamera
set_controls
create_gst_libcamera_livestream_pipeline

LIBCAMERA_PIPELINES_MATCH_LIST='nxp/neo' gst-launch-1.0 ${PIPELINE}
