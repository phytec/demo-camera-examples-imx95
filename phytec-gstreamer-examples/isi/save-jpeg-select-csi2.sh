#!/bin/sh

# Only evaluated if phyCAM-L camera connected.
PHYCAM_L_PORT=0

source /usr/share/phytec-gstreamer-examples/tools/func.sh

detect_sensor_type "ISI" "CSI2" $PHYCAM_L_PORT
select_format
select_mode_interactive

MODE_NAME="$(echo ${CAM_MODENAME} | cut -d' ' -f-2 | sed 's# #_#g')"

echo "================================================================================="
echo "Start saving a JPEG Image from ${CAM_PHYCAM_NAME} with gstreamer on ${INTERFACE} via ${PROC}"
echo "Configured Sensor Mode: ${CAM_MODENAME}"
echo "Capturing ${CAP_WIDTH}x${CAP_HEIGHT} with ${CAP_FMT} from ${CAP_DEVICE},"
echo "converting it to JPEG and saving it as ${CAM_NAME}_${CAM_COLOR}_${MODE_NAME}_${PROC}.jpg"
echo "================================================================================="

set_mode
set_controls

create_gst_save_jpeg_pipeline

gst-launch-1.0 ${PIPELINE}
