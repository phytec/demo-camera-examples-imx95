==================
Dewarping with DPU
==================

For the VM-016, VM-017 and VM-020 there is Dewarping Calibration Data for the Sensor and two
standard lenses available.

Dewarping can be used either with the ISI or the ISP.

Dewarping on DPU with gstreamer
===============================

To use dewarping in a gstreamer pipeline use the imxvideoconvert_g2d plugin. It can be integrated
in an ISI and ISP pipeline, see the following two examples.
You have to match the selected calibration data to the sensor, lens and resolution used.

ISI:

target$ setup-pipeline-csi1
target$ gst-launch-1.0 v4l2src device=/dev/video-isi-csi1 ! \
            video/x-bayer,format=grbg,width=1920,height=1200 ! \
            bayer2rgbneon ! \
            imxvideoconvert_g2d \
              video-warp-enable=true \
              video-warp-coord-file=/usr/share/phycam-imx-dewarp/Dewarp_VM-x20_AO082_1920x1200.bin ! \
            waylandsink sync=false

ISP:

target$ LIBCAMERA_PIPELINES_MATCH_LIST='nxp/neo' gst-launch-1.0 \
            libcamerasrc \
              camera-name=/base/soc/bus@42000000/i2c@42530000/camera@10 \
              ae-enable=true ! \
            imxvideoconvert_g2d \
              video-warp-enable=true \
              video-warp-coord-file=/usr/share/phycam-imx-dewarp/Dewarp_VM-x20_AO082_1920x1200.bin ! \
            video/x-raw,format=YUY2,width=1920,height=1200 ! \
            waylandsink sync=false
