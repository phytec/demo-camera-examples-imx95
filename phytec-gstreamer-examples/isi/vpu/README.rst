Gstreamer VPU Encoding Examples
===============================

Scripts
-------

* save-h264-mkv-1280x720.sh
  This example saves a HD video stream from the connected camera, H264
  encoded in an MKV file.

* capture-h264-network-stream-1280x720.sh
  This example streams an HD video stream H264 encoded to the network, which
  can be accessed e.g. with VLC on a connected host PC.
  The provided VLC_Network_Stream.sdp can be used to access the provided
  stream on the host PC.
  Make sure to set the correct IP address of your target board in
  VLC_Network_Stream.sdp and the correct IP address of your host PC in the
  script.

  Note: To improve the delay on the received stream you can adjust the
  Network Caching parameter in VLC, which is set to 1000 ms by default.
  To adjust this setting, make sure to select "Show Settigns - All" under
  VLC -> Tools -> Preferences and find the Network Caching parameter under
  "Inputs/Codecs" in the "Advanced" section at the bottom.
