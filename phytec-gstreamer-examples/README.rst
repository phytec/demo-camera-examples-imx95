==================
Gstreamer Examples
==================

PHYTEC phyCAM Gstreamer Examples
================================

All phyCAM examples autodetect the connected camera and let you know what
configuration steps were required to configure the detected camera sensor and
interface.

There are separate subfolders for ISI and ISP examples and all examples are
available for the CSI1 and CSI2 interface.

To use the available scripts with a phyCAM-L, make sure to select the correct
port used in the script itself. By default Port0 is used.

Following phyCAM examples are available for the ISI:

* capture-liveview-1280x720.sh
  This example captures an HD video stream from the connected sensor and
  shows it on a connected display.

* capture-liveview-select.sh
  This example lets you select one of the available configurations and
  captures the corresponding stream from the sensor and shows it on a
  connected display.

* save-jpeg-full.sh
  This example saves a full resolution frame from the connected sensor in
  JPEG format.

* save-jpeg-select.sh
  This examples lets you select one of the available configurations of the
  connected sensor and saves the corresponding frame in JPEG format.

* save-raw-full.sh
  This example saves a full resolution frame from the connected sensor in a
  raw format containing the unprocessed data from the sensor.

* save-raw-select.sh
  This examples lets you select one of the available configurations of the
  connected sensor and saves the corresponding frame in a raw format
  containing the unprocessed data from the sensor.

Following phyCAM examples are available for the ISP:

* capture-libcamera-liveview.sh
  This example captures a full resolution stream from the conncected sensor
  and shows it on a connected display.
  This examples uses libcamera instead of plain V4L2.


Additional Gstreamer Examples
=============================

Subfolders isi/vpu/ and isp/vpu contain additional examples showing the use of
VPU accelerated H264 encoding.

Subfolder phytec_usb_cam/ contains additional examples to work with PHYTECs
USB cameras.


Tools
=====

The tools/ subfolder contains some helper scripts regarding camera sensor
register access and the PHYTEC Qt Demo.


V4L2-Controls
=============

V4L2 controls are a way to modify the behavior of the camera sensor or monitor
specific settings.

To access V4L2 controls of the camera sensor the v4l2-ctl command needs to be
supplied with the corresponding V4L2 subdevice. Use one of the following:

phyCAM-M:         /dev/cam-csi1
pyhCAM-L Port0:   /dev/cam-csi1-port0
pyhCAM-L Port1:   /dev/cam-csi1-port1


List all available controls and their values
--------------------------------------------
::

  v4l2-ctl -d <SENSOR_SUBDEV> -L


Common V4L2 controls
--------------------

* LINK_FREQUENCY:
  Let's you read the configured MIPI-CSI2 Link frequency in Hz. It contains one
  value for each available bit width with following relation:
  Pos 0: 8 Bit Link Frequency
  Pos 1: 10 Bit Link Frequency
  Pos 2: 12 Bit Link Frequecny

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -C link_frequency

* PIXEL_RATE:
  The pixel_rate control let's you read back the configured pixelclock setting
  for the current configuration in Hz.

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -C pixel_rate

* HORIZONTAL/VERTICAL_FLIP:
  Flip the horizontal and/or vertical sensor readout direction.

  Examples::

    v4l2-ctl -d <SENSOR_SUBDEV> -c horizontal_flip=1
    v4l2-ctl -d <SENSOR_SUBDEV> -c vertical_flip=1

  Note:
    With the AR0521 (VM-X17) sensor the bayer sequence of the resulting
    image changes with horizontal and vertical flipping.
    H/V=0 -> grbg, H=1/V=0 -> rggb, H=0/V=1 -> bggr, H/V=1 -> gbrg

* EXPOSURE:
  Sets the exposure time of the sensor. It is set in multiples of the sensors
  configured row time, best explained with an example:
  Pixelclock = 414 MHz
  Width = 2592
  Horizontal Blanking = 488
  Row Time = (2592 + 488) / 414 MHz = 0.00744 ms
  So to achieve a 16.666 ms exposure time (60 FPS) the exposure control needs
  to be set to 2240. (16.666 ms / 0.00744 ms = 2240)

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c exposure=2240

  Note:
    Be aware, that increasing the exposure setting above the configured
    height of the image plus vertical blanking will affect the captured FPS
    because the exposure of a frame will take longer than its frame time.

* VERTICAL BLANKING:
  Number of blanking rows. (Can only be adjusted when sensor is stopped)

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c vertical_blanking=28

* HORIZONTAL BLANKING:
  Number of blanking columns. (Can only be adjusted when sensor is stopped)

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c horizontal_blanking=28

* DEFECT PIXEL CORRECTION
  The supported sensors include a dynamic defect pixel correction, which can
  be enabled by setting the corresponding control to 1.

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c dynamic_defect_pixel_correction=1

* TEST PATTERN
  The supported sensors can be configured to output specific test patterns
  instead of the actual captured frame. To see all supported test patterns use
  v4l2-ctl -d <SENSOR_SUBDEV> -L.
  For the test pattern 'solid_color', the color to use can be selected by the
  _pixel_value controls (See example). The maximum allowed value here is all
  bits set for the maximum bit width, for 12 bit sensors it is 4095 (ar0144
  and ar0521) and for 10 bit sensors it is 1024 (ar0234).

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c test_pattern=1
    v4l2-ctl -d <SENSOR_SUBDEV> -c red_pixel_value=512
    v4l2-ctl -d <SENSOR_SUBDEV> -c green_red_pixel_value=512
    v4l2-ctl -d <SENSOR_SUBDEV> -c blue_pixel_value=512
    v4l2-ctl -d <SENSOR_SUBDEV> -c green_blue_pixel_value=512


AR0144/AR0234 specific Controls
-------------------------------

* FINE EXPOSURE
  Delay the shutter in pixel (if AEC is off). Additional period of time,
  (after the in exposure defined rows) in columns.

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c exposure_fine=10

* COLUMN BINNING
  Use Binning instead of skipping for columns, if skipping is configured.
  Select either 'averaged' or 'summed' mode.

  0 = Off / 1 = Average / 2 = Summed

  Recommended when column-wise skipping is enabled.

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c col_binning=2

* ROW BINNING
  Use Binning instead of skipping for rows, if skipping is configured.

  0 = Off / 1 = Average

  Recommended when row-wise skipping is enabled.

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c row_binning=1

* GAIN:
  The sensors feature two separate gain controls, analogue gain and digital
  gain. The resulting total gain is the product of analogue and digital gain.

  Total Gain = Analogue Gain * Digital Gain.

  These are the valid gain ranges:

  AR0144 (VM-x16)
  * Analogue: [1.684..16]x (1684..16000)
  * Digital: [1..15.999]x (1000..15999)

  AR0234 (VM-x20)
  * Analogue: [1.684..16]x (1684..16000)
  * Digital: [1..15.999]x (1000..15999)

  Examples::

    v4l2-ctl -d <SENSOR_SUBDEV> -c analogue_gain=5500 (5.5x analogue gain)
    v4l2-ctl -d <SENSOR_SUBDEV> -c digital_gain=2700 (2.7x digital gain)

  Note:
    First use the whole range of the analogue gain, before starting to
    increase the digital gain.

* AUTOMATIC EXPOSURE CONTROL
  The ar0144 and ar0234 sensors feature an automatic exposure control (AEC)
  unit.
  It uses the same format as the common exposure control.
  Following controls are available to configure it:

  * auto_exposure: 0 = AEC on / 1 = AEC off
  * auto_exposure_min: Minimum exposure value allowed when using AEC
  * auto_exposure_max: Maximum exposure value allowed when using AEC
  * auto_exposure_target: Average green target value to be reached by AEC
  * auto_exposure_cur: Read the exposure value currently set by the AEC

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c auto_exposure=0
    v4l2-ctl -d <SENSOR_SUBDEV> -c auto_exposure_min=1
    v4l2-ctl -d <SENSOR_SUBDEV> -c auto_exposure_max=827
    v4l2-ctl -d <SENSOR_SUBDEV> -c auto_exposure_target=20480
    v4l2-ctl -d <SENSOR_SUBDEV> -C auto_exposure_cur

* AUTOMATIC GAIN CONTROL
  The ar0144 and ar0234 sensors feature an automatic gain control (AGC) unit.
  It can control both analogue and digital gain.
  Following controls are available to configure them:

  * autogain_analogue: Enable/Disable analogue AGC (Enable = 1 / Disable = 0)
  * analogue_gain_auto_min: Minimum analogue gain to be used, choose from:
                            0=1x, 1=2x, 2=4x, 3=8x
  * autogain_digital: Enable/Disable digital AGC (Enable = 1 / Disable = 0)

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c autogain_analogue=1
    v4l2-ctl -d <SENSOR_SUBDEV> -c analogue_gain_auto_min=1
    v4l2-ctl -d <SENSOR_SUBDEV> -c autogain_digital=0

* COMPADING
  Activate A-Law compression.

  0 = Off / 1 = Companding on

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c compading=1

* BLACK LEVEL CORRECTION
  Activate automatic black level correction (BLC).

  0 = BLC off / 1 = BLC on

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c black_level_correction=1

* TRIGGER MODE
  Select the trigger mode to use.

  0 = No trigger / 1 = Trigger used

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c trigger_mode=1

* FLASH/STROBE
  Configure to use flash or strobe mode.

  0 = Strobe / 1 = Flash

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c led_mode=1

* FLASH/STROBE START POSITION
  Configures the start position of the flash signal based on the start of the
  integration process. Set in row_time / 2 steps (For an example of row time
  calculation see the common exposure control).

  Range [-128..127]

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c flash_delay=-4


AR0521 specific Controls
------------------------

* COLUMN BINNING
  Use Binning instead of skipping for columns, if skipping is configured.

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c column_binning=1

  Note:
    Only available with color cameras.

* VERTICAL FINE BLANKING
  Extra blanking (clocks) inserted between frames.

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c extra_vertical_blanking=15

* GAIN:
  The sensor features two separate gain controls, analogue gain and digital
  gain. The resulting total gain is the product of analogue and digital gain.

  Total Gain = Analogue Gain * Digital Gain.

  These are the valid gain ranges:

  Analogue: [1.000..14.25]x (1000..14250)
  Digital: [1..7.999]x (1000..7999)

  Examples::

    v4l2-ctl -d <SENSOR_SUBDEV> -c analogue_gain=5500 (5.5x analogue gain)
    v4l2-ctl -d <SENSOR_SUBDEV> -c digital_gain=2700 (2.7x digital gain)

  Note:
    First use the whole range of the analogue gain, before starting to
    increase the digital gain.

* INVERT FLASH
  Invert the flash signal.

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c invert_flash=1

* FLASH XENON WIDTH
  Width of the flash signal.

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c flash_xenon_width=256

* TRIGGER MODE
  Mode in which the trigger signal is configured.
  * 0 = Off
  * 1 = Global Reset Release
  * 2 = Electronic Rolling Shutter

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c trigger_mode=1

* TRIGGER PIN
  Configure the General Purpose Input (GPI) pin to use as trigger input.
  * 0 = Set Trigger at Pin GPI0
  * 1 = Set Trigger at Pin GPI1
  * 2 = Set Trigger at Pin GPI2

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c trigger_pin=2

* FLASH/STROBE
  * 0 = FLASH/TORCH off
  * 1 = FLASH
  * 2 = TORCH

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c led_mode=1


AR0830 specific Controls
------------------------

* COLUMN BINNING
  Use Binning instead of skipping for columns, if skipping is configured.

  0 = Off / 1 = Average

  Recommended when column-wise skipping is enabled.

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c column_binning_enable=1

* ROW BINNING
  Use Binning instead of skipping for rows, if skipping is configured.

  0 = Off / 1 = Average

  Recommended when row-wise skipping is enabled.

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c row_binning_enable=1

* GAIN:
  The sensor features a global gain control, which includes analogue gain and
  digital gain. Every step in gain code increases the total gain by 0.375 dB.

  The valid gain range is:

  Gain: [1.0..480.0]x (0..143)

  Examples::

    v4l2-ctl -d <SENSOR_SUBDEV> -c gain=16 (total 6 dB)

* AUTOMATIC EXPOSURE CONTROL
  The ar0830 sensor features an automatic exposure control (AEC)
  unit. It uses the same format as the common exposure control.
  Following controls are available to configure it:

  * auto_exposure: 0 = AEC on / 1 = AEC off
  * auto_exposure_min: Minimum exposure value allowed when using AEC
  * auto_exposure_max: Maximum exposure value allowed when using AEC
  * auto_exposure_target_luma: Average green target value to be reached by AEC

  Note:
    The current active exposure can be read from the exposure control, as long
    as the AEC is enabled.

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c auto_exposure=0
    v4l2-ctl -d <SENSOR_SUBDEV> -c auto_exposure_min=1
    v4l2-ctl -d <SENSOR_SUBDEV> -c auto_exposure_max=2160
    v4l2-ctl -d <SENSOR_SUBDEV> -c auto_exposure_target=20480

* AUTOMATIC GAIN CONTROL
  The ar0830 sensor features an automatic gain control (AGC) unit.

  Following controls are available to configure them:
  * gain_automatic: Enable/Disable analogue AGC (Enable = 1 / Disable = 0)

  Example::

    v4l2-ctl -d <SENSOR_SUBDEV> -c gain_automatic=1

  Note:
    AGC can only be used in combination with AEC and should be turned off when
    AEC is turned off as well. Otherwise manual gain control is not available.
