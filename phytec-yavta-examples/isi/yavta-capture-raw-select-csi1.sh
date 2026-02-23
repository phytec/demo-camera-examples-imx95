#!/bin/sh

# Only evaluated if phyCAM-L camera connected.
PHYCAM_L_PORT=0

source /usr/share/phytec-gstreamer-examples/tools/func.sh

detect_sensor_type "ISI" "CSI1" $PHYCAM_L_PORT
select_format_interactive
select_mode_interactive

set_mode
set_controls

MODE_NAME="$(echo ${CAM_MODENAME} | cut -d' ' -f-2 | sed 's# #_#g')"
FILE_NAME="${CAM_NAME}_${CAM_COLOR}_${YAVTA_FMT}_${MODE_NAME}.raw"

if [ -e ${FILE_NAME} ] ; then
	rm ${FILE_NAME}
fi

echo "================================================================================="
echo "Starting Yavta with ${CAM_FMT} Source on ${INTERFACE} via ${PROC}"
echo "Configured Sensor Mode: ${CAM_MODENAME}"
echo "Capturing ${CAP_WIDTH}x${CAP_HEIGHT} with ${YAVTA_FMT} from ${CAP_DEVICE}"
echo "and saving the raw data as ${FILE_NAME}"
echo "================================================================================="

SIZE="${CAP_WIDTH}x${CAP_HEIGHT}"
COUNT="8"
SKIP="7"

echo "  yavta -c${COUNT} --skip ${SKIP} -s${SIZE} \\"
echo "        -f${YAVTA_FMT} -F${FILE_NAME} ${CAP_DEVICE}"
echo ""

yavta -c${COUNT} --skip ${SKIP} -s${SIZE} -f${YAVTA_FMT} -F${FILE_NAME} ${CAP_DEVICE}
