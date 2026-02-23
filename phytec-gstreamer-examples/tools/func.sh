#!/bin/sh
# i.MX 8M Plus, version V3.0, Phytec 08.2024

select_interface() {
	echo "Select Camera Interface to Use"
	echo "=============================="
	echo "  1 = CSI1 phyCAM-M"
	echo "  2 = CSI2 phyCAM-M"
	echo "  3 = CSI1 phyCAM-L Port 0"
	echo "  4 = CSI1 phyCAM-L Port 1"
	echo "  5 = CSI2 phyCAM-L Port 0"
	echo "  6 = CSI2 phyCAM-L Port 1"

	read IFACE_INDEX

	if [ -z "$IFACE_INDEX" ] ; then
		INTERFACE="CSI1"
		PHYCAM_L_PORT=0
	else
		case $IFACE_INDEX in
			"1")
				INTERFACE="CSI1"
				PHYCAM_L_PORT=0
				;;
			"2")
				INTERFACE="CSI2"
				PHYCAM_L_PORT=0
				;;
			"3")
				INTERFACE="CSI1"
				PHYCAM_L_PORT=0
				;;
			"4")
				INTERFACE="CSI1"
				PHYCAM_L_PORT=1
				;;
			"5")
				INTERFACE="CSI2"
				PHYCAM_L_PORT=0
				;;
			"6")
				INTERFACE="CSI2"
				PHYCAM_L_PORT=1
				;;
		esac
	fi
}

detect_sensor_type() {

	if [ -z "$1" ] ; then
		PROC="ISI"
	else
		PROC="$1"
	fi

	if [ -z "$2" ] ; then
		INTERFACE="CSI1"
	else
		INTERFACE="$2"
	fi

	if [ -z "$3" ] ; then
		PORT="0"
	else
		PORT="$3"
	fi

	IFACE="$(echo "$INTERFACE" | awk '{print tolower($0)}')"

	CAM_DEV=""
	PORT_EXT=""
	if [ -L "/dev/cam-${IFACE}" ] ; then
		CAM_DEV="/dev/cam-${IFACE}"
	elif [ -L "/dev/cam-${IFACE}-port0" ] && [ "$PORT" = "0" ] ; then
		CAM_DEV="/dev/cam-${IFACE}-port0"
		PORT_EXT="-port0"
	elif [ -L "/dev/cam-${IFACE}-port1" ] && [ "$PORT" = "1" ] ; then
		CAM_DEV="/dev/cam-${IFACE}-port1"
		PORT_EXT="-port1"
	else
		echo "No camera detected on interface ${IFACE}"
		exit 1
	fi

	CAP_DEVICE="/dev/video-isi-${IFACE}${PORT_EXT}"

	if [ -z "$CAP_DEVICE" ] ; then
		echo "Video device not found: ${CAP_DEVICE}"
		exit 1
	fi

	CAM_SUBDEV="$(readlink ${CAM_DEV})"
	CAM_ENT="$(cat /sys/class/video4linux/${CAM_SUBDEV}/name)"
	CAM_NAME="$(echo ${CAM_ENT} | cut -d" " -f1)"

	CAM_FWNODE_PATH="$(readlink -f /sys/class/video4linux/${CAM_SUBDEV}/device/of_node)"
	LIBCAM_NAME="${CAM_FWNODE_PATH##/sys/firmware/devicetree}"

	COLOR="$(v4l2-ctl -d ${CAM_DEV} --get-subdev-fmt 0 | \
		grep "Mediabus Code" | \
		sed 's/.*BUS_FMT_\([A-Z]*\).*/\1/g')"
	if [ "$COLOR" = "Y" ]; then
		CAM_COLOR="BW"
	else
		CAM_COLOR="COL"
	fi

	echo "Detected ${CAM_NAME} ${CAM_COLOR} Sensor on ${INTERFACE}"
	if [ -L "/dev/phycam-serializer-port${PORT}-${IFACE}" ] ; then
		echo "connected via phyCAM-L Port ${PORT}"
	fi
	echo ""

	if [ "$PROC" = "ISI" ] ; then
		CONFIG_EXT=""
	else
		CONFIG_EXT="-isp"
	fi

	CONFIG_PATH="/usr/share/phytec-gstreamer-examples/tools/"
	case $CAM_NAME in
		ar0144 )
			CONFIG_FILE="ar0144${CONFIG_EXT}.conf"
			;;
		ar0234 )
			CONFIG_FILE="ar0234${CONFIG_EXT}.conf"
			;;
		ar0521 )
			CONFIG_FILE="ar0521${CONFIG_EXT}.conf"
			;;
		ar0830 )
			CONFIG_FILE="ar0830${CONFIG_EXT}.conf"
			;;
		* ) echo "Unknown camera: ${CAM_NAME}" ; exit 1
	esac

	if [ -f "${CONFIG_PATH}${CONFIG_FILE}" ] ; then
		source ${CONFIG_PATH}${CONFIG_FILE}
	else
		echo "Camera Sensor Configuration File not found:"
		echo "${CONFIG_PATH}${CONFIG_FILE}"
		exit 1
	fi

}

select_format_interactive() {
	camera_select_format_interactive
}

select_format() {
	camera_select_format "$1"
}

set_mode() {
	if [ "$INTERFACE" = "CSI1" ] ; then
		setup-pipeline-csi1 -f "${CAM_FMT}" -s "${CAP_WIDTH}x${CAP_HEIGHT}" \
			-c "${CAM_WIDTH}x${CAM_HEIGHT}" -o "(${CAM_OFFSET_LEFT},${CAM_OFFSET_TOP})" \
			-p "${PHYCAM_L_PORT}"
	elif [ "$INTERFACE" = "CSI2" ] ; then
		setup-pipeline-csi2 -f "${CAM_FMT}" -s "${CAP_WIDTH}x${CAP_HEIGHT}" \
			-c "${CAM_WIDTH}x${CAM_HEIGHT}" -o "(${CAM_OFFSET_LEFT},${CAM_OFFSET_TOP})" \
			-p "${PHYCAM_L_PORT}"
	else
		echo "Invalid Interface: ${INTERFACE}"
		exit 1
	fi
}

set_mode_libcamera() {

	MC="media-ctl -d /dev/media-isi"
	CROP="(${CAM_OFFSET_LEFT},${CAM_OFFSET_TOP})/${CAM_WIDTH}x${CAM_HEIGHT}"
	FMT="${CAM_FMT}/${CAM_WIDTH}x${CAM_HEIGHT}"

	echo ""
	echo "Setting up Sensor Crop ${INTERFACE}"
	echo "---------------------------"
	echo "   $MC -V \"'${CAM_ENT}':0/0[fmt: ${FMT} crop:${CROP}]\""
	$MC -V "'${CAM_ENT}':0/0[crop:${CROP}]"
	echo ""

	if [ -d "/tmp/setup-routing" ]; then
		rm /tmp/setup-routing/*
	fi

}

select_mode_interactive() {
	camera_select_mode_interactive

	if [ -n "$GST_FMT" ] ; then
		GST_FMT="${GST_FMT},width=${CAP_WIDTH},height=${CAP_HEIGHT}"
	fi

	if [ -n "$CAM_FMT_CTRLS" ] ; then
		CAM_CTRLS="$CAM_FMT_CTRLS,$CAM_MODE_CTRLS"
	else
		CAM_CTRLS="$CAM_MODE_CTRLS"
	fi
}

select_mode() {
	camera_select_mode "$1"

	if [ -n "$GST_FMT" ] ; then
		GST_FMT="${GST_FMT},width=${CAP_WIDTH},height=${CAP_HEIGHT}"
	fi

	if [ -n "$CAM_FMT_CTRLS" ] ; then
		CAM_CTRLS="$CAM_FMT_CTRLS,$CAM_MODE_CTRLS"
	else
		CAM_CTRLS="$CAM_MODE_CTRLS"
	fi
}

set_controls() {

	echo ""
	if [ -n "$CAM_CTRLS" ] ; then
		echo " Setting Sensor V4L2 Controls:"
		echo " -----------------------------"
		CTRLS=$(echo "$CAM_CTRLS" | sed 's/,/ /g')
		for CTRL in ${CTRLS} ; do
			echo "  v4l2-ctl -d ${CAM_DEV} -c ${CTRL}"
		done
		echo ""
		v4l2-ctl -d "${CAM_DEV}" -c "${CAM_CTRLS}"
	fi

	if [ "${CAM_NAME}" = "ar0521" ] && [ "$PROC" = "ISI" ] ; then
		echo "  Since the ${CAM_PHYCAM_NAME} does not feature an internal AEC algorithm,"
		echo "  using this example in low light conditions can result in very dark images."
		echo "  To improve this, you can increase the analogue gain setting with"
		echo "     v4l2-ctl -d ${CAM_DEV} -c analogue_gain=8000"
		echo ""
	fi
}

create_gst_livestream_pipeline() {

	SOURCE="v4l2src device=${CAP_DEVICE} ${GST_SRC_OPTS}"
	SINK="waylandsink sync=false"

	if [ -z "$GST_FMT" ]; then
		echo "Camera Sensor ${CAM_PHYCAM_NAME} does not support 8 bit capture."
		exit 1
	fi

	echo "GStreamer Pipeline"
	echo "=================="
	echo "  gst-launch-1.0 ${SOURCE} ! \\"
	echo "    ${GST_FMT} ! \\"
	if [ -n "${GST_CONV}" ] ; then
		echo "    ${GST_CONV} ! \\"
	fi
	echo "    ${SINK}"
	echo ""

	PIPELINE="${SOURCE} ! ${GST_FMT}"
	if [ -n "${GST_CONV}" ] ; then
		PIPELINE="${PIPELINE} ! ${GST_CONV}"
	fi
	PIPELINE="${PIPELINE} ! ${SINK}"
}

create_gst_livestream_dual_pipeline() {

	SOURCE1="v4l2src device=${CAM1_CAP_DEVICE} ${CAM1_GST_SRC_OPTS}"
	SOURCE2="v4l2src device=${CAM2_CAP_DEVICE} ${CAM2_GST_SRC_OPTS}"
	COMP="imxcompositor_g2d name=mix"
	COMP_SINK0="sink_0::xpos=0 sink_0::ypos=100 sink_0::width=640 sink_0::height=400"
	COMP_SINK1="sink_1::xpos=640 sink_1::ypos=100 sink_1::width=640 sink_1::height=400"
	SINK="waylandsink"

	if [ -z "$CAM1_GST_FMT" ]; then
		echo "Camera Sensor ${CAM1_PHYCAM_NAME} does not support 8 bit capture."
		exit 1
	fi

	if [ -z "$CAM2_GST_FMT" ]; then
		echo "Camera Sensor ${CAM2_PHYCAM_NAME} does not support 8 bit capture."
		exit 1
	fi

	echo "GStreamer Pipeline"
	echo "=================="
	echo "  gst-launch-1.0 ${COMP} \\"
	echo "    ${COMP_SINK0} \\"
	echo "    ${COMP_SINK1} ! \\"
	echo "    ${SINK} \\"
	echo "    ${SOURCE1} ! \\"
	echo "    ${CAM1_GST_FMT} ! \\"
	if [ -n "${CAM1_GST_CONV}" ] ; then
		echo "    ${CAM1_GST_CONV} ! \\"
	fi
	echo "    mix. \\"
	echo "    ${SOURCE2} ! \\"
	echo "    ${CAM2_GST_FMT} ! \\"
	if [ -n "${CAM2_GST_CONV}" ] ; then
		echo "    ${CAM2_GST_CONV} ! \\"
	fi
	echo "    mix."
	echo ""

	PIPELINE="${COMP} ${COMP_SINK0} ${COMP_SINK1} ! ${SINK}"
	PIPELINE="${PIPELINE} ${SOURCE1} ! ${CAM1_GST_FMT} !"
	if [ -n "${CAM1_GST_CONV}" ] ; then
		PIPELINE="${PIPELINE} ${CAM1_GST_CONV} !"
	fi
	PIPELINE="${PIPELINE} mix."

	PIPELINE="${PIPELINE} ${SOURCE2} ! ${CAM2_GST_FMT} !"
	if [ -n "${CAM2_GST_CONV}" ] ; then
		PIPELINE="${PIPELINE} ${CAM2_GST_CONV} !"
	fi
	PIPELINE="${PIPELINE} mix."
}

create_gst_save_jpeg_pipeline() {

	SOURCE="v4l2src device=${CAP_DEVICE} num-buffers=${CAP_FRAME_CNT} ${GST_SRC_OPTS}"
	ENCODING="jpegenc"

	if [ -z "$GST_FMT" ]; then
		echo "Camera Sensor ${CAM_PHYCAM_NAME} does not support 8 bit capture."
		exit 1
	fi

	if [ -n "$MODE_NAME" ] ; then
		FILENAME="${CAM_NAME}_${CAM_COLOR}_${MODE_NAME}_${PROC}.jpg"
	else
		FILENAME="${CAM_NAME}_${CAM_COLOR}_${PROC}.jpg"
	fi

	SINK="multifilesink location=${FILENAME}"

	echo "GStreamer Pipeline"
	echo "=================="
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
}

create_gst_save_raw_pipeline() {

	SOURCE="v4l2src device=${CAP_DEVICE} num-buffers=${CAP_FRAME_CNT} ${GST_SRC_OPTS}"

	if [ -z "$GST_FMT" ]; then
		echo "Camera Sensor ${CAM_PHYCAM_NAME} does not support 8 bit capture."
		exit 1
	fi

	if [ -n "$MODE_NAME" ] ; then
		FILENAME="${CAM_NAME}_${CAM_COLOR}_${MODE_NAME}_${PROC}.${FILE_EXTENSION}"
	else
		FILENAME="${CAM_NAME}_${CAM_COLOR}_${PROC}.${FILE_EXTENSION}"
	fi

	SINK="multifilesink location=${FILENAME}"

	echo "GStreamer Pipeline"
	echo "=================="
	echo "  gst-launch-1.0 ${SOURCE} ! \\"
	echo "    ${GST_FMT} ! \\"
	echo "    ${SINK}"
	echo ""

	PIPELINE="${SOURCE} ! ${GST_FMT} ! ${SINK}"
}

create_gst_libcamera_livestream_pipeline() {

	if [ "$PROC" = "ISI" ]; then
		STREAM_ROLE="src::stream-role=raw"
		AE_CTRL=""
		PIPELINE_MATCH="LIBCAMERA_PIPELINES_MATCH_LIST='imx8-isi'"
	else
		STREAM_ROLE="src::stream-role=video-recording"
		AE_CTRL="ae-enable=true"
		PIPELINE_MATCH="LIBCAMERA_PIPELINES_MATCH_LIST='nxp/neo'"
	fi

	SOURCE="libcamerasrc camera-name=${LIBCAM_NAME} ${AE_CTRL} ${STREAM_ROLE}"
	SINK="waylandsink sync=false"

	echo "GStreamer Pipeline"
	echo "=================="
	echo "  ${PIPELINE_MATCH} gst-launch-1.0 ${SOURCE} ! \\"
	echo "    ${GST_FMT} ! \\"
	if [ -n "${GST_CONV}" ] ; then
		echo "    ${GST_CONV} ! \\"
	fi
	echo "    ${SINK}"
	echo ""

	PIPELINE="${SOURCE} ! ${GST_FMT}"
	if [ -n "${GST_CONV}" ] ; then
		PIPELINE="${PIPELINE} ! ${GST_CONV}"
	fi
	PIPELINE="${PIPELINE} ! ${SINK}"
}
