#!/bin/sh

# Only evaluated if phyCAM-L camera connected.
PHYCAM_L_PORT=0

source /usr/share/phytec-gstreamer-examples/tools/func.sh

detect_sensor_type "ISI" "CSI1" $PHYCAM_L_PORT
select_format
select_mode "Dual"
set_mode
set_controls

CAM1_PHYCAM_NAME="$CAM_PHYCAM_NAME"
CAM1_CAP_DEVICE="$CAP_DEVICE"
CAM1_GST_FMT="$GST_FMT"
CAM1_GST_CONV="$GST_CONV"
CAM1_GST_SRC_OPTS="$GST_SRC_OPTS"

PHYCAM_L_PORT=0

detect_sensor_type "ISI" "CSI2" $PHYCAM_L_PORT
select_format
select_mode "Dual"
set_mode
set_controls

CAM2_PHYCAM_NAME="$CAM_PHYCAM_NAME"
CAM2_CAP_DEVICE="$CAP_DEVICE"
CAM2_GST_FMT="$GST_FMT"
CAM2_GST_CONV="$GST_CONV"
CAM2_GST_SRC_OPTS="$GST_SRC_OPTS"

echo "================================================================================="
echo "Starting DualCam ISI Gstreamer Livestream Pipeline with"
echo "${CAM1_PHYCAM_NAME} on CSI1 and ${CAM2_PHYCAM_NAME} on CSI2"
echo "================================================================================="

create_gst_livestream_dual_pipeline

gst-launch-1.0 ${PIPELINE}
