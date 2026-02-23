PHYTEC USB Camera Gstreamer Examples
====================================

Supported Cameras
-----------------

* USB-CAM-003H (with UVC Firmware update)
* USB-CAM-103H (with UVC Firmware update) (trigger not supported)
* USB-CAM-051H (with UVC Firmware update)
* USB-CAM-151H (with UVC Firmware update) (trigger not supported)
* USB-CAM-004H (with UVC Firmware update)
* USB CAM 104H (with UVC Firmware update) (trigger not supported)
* USB-CAM-052H (with UVC Firmware update)
* USB CAM 152H (with UVC Firmware update) (trigger not supported)

USB-CAM-x5x support following resolutions:

* 2592x1944
* 1920x1080
* 1280x720
* 640x480

Note:
  The UVC Firmware can only be updated by PHYTEC at the moment.

Scripts
-------

The following scripts are available:

* usb_bwcam-fbdev_640x480.sh
  A monochrome live image with a 640x480 resolution is shown on the display.

* usb_bwcam-save_jpg_full_res.sh
  A monochrome JPG image is saved with full resolution.

* usb_bwcam-save_raw_full_res.sh
  A monochrome RAW image is saved with full resolution.

* usb_colcam-fbdev_640x480.sh
  A color live image with a 640x480 resolution is shown on the display.

* usb_colcam-save_jpg_full_res.sh
  A color JPG image is saved with full resolution.

* usb_colcam-save_raw_full_res.sh
  A color RAW image is saved with full resolution.


V4L2-Controls
-------------

v4l2-ctl can be used to change the gain or the exposure time of the USB
cameras.

Use the following command to get an overview of the available
functions:
* v4l2-ctl -d /dev/video[x] -L

To change gain or exposure, the following commands can be used:
* v4l2-ctl -d /dev/video[x] -c gain=xx	(xx=16-63)
* v4l2-ctl -d /dev/video[x] -c exposure_absolute=xx (xx=1-2500)

Note:
  The driver must be loaded.
