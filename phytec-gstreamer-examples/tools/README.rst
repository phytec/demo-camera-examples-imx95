===============
4. Helper/Tools
===============

Besides some helpful scripts, see below, this directory contains the sensor
configuration and auto detection scripts used by the gstreamer examples.

Qt Demo
=======

The PHYTEC Qt Demo can be enabled or disabled as desired:

* Enable for the current session:    systemctl start phytec-qtdemo
* Enable during boot:                systemctl enable phytec-qtdemo
* Disable for the current session:   systemctl stop phytec-qtdemo
* Disable during boot:               systemctl disable phytec-qtdemo

There is also a small helper script to stop and disable the Qt Demo:
    ./tools/remove_qt_demo.sh


I2C Camera Sensor Register Access
=================================

The PHYTEC phyCAM sensors feature 16 bit wide address and data registers on the
I2C bus. Due to that the tools i2cdump, i2cget and i2cset can't be used out of
the box.

The following scripts allow you to access the camera sensor registers:

i2cdump_16bit_adr [Number I2C-Bus] [I2C Adress Camera] [Adress AR0144 Register]
i2cget_16bit_adr  [Number I2C-Bus] [I2C Adress Camera] [Adress AR0144 Register]
i2cset_16bit_adr  [Number I2C-Bus] [I2C Adress Camera] [Adress AR0144 Register] [Value to set]

* AR0144/AR0234
  examples::

    ./tools/i2cdump_16bit_adr.sh 2 0x10 0x3000
    ./tools/i2cget_16bit_adr.sh 2 0x10 0x3000
    ./tools/i2cset_16bit_adr.sh 2 0x10 0x3040 0x8000

* AR0521/AR0522
  examples::

    ./tools/i2cdump_16bit_adr.sh 2 0x36 0x3000
    ./tools/i2cget_16bit_adr.sh 2 0x36 0x3000
    ./tools/i2cset_16bit_adr.sh 2 0x36 0x3040 0x8000
