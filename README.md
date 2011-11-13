Basic Node.js AirPlay client (the part that sends the video to the screen) library
=

airplayer is a basic module for sending videos to AirPlay-compatible devices. mDNS (Bonjour, Avahi) service resolution is intentionally missing, you'll have to do it yourself.


Requirements
-

If you want to use playback_info, you'll need the plist module

Usage
-

    Airplayer = require('airplayer')
    example = new Airplayer('192.168.3.106', 6002) # yes, ip.
    example.playfile "/home/gazs/movie.mp4" 

Methods
-

* **playurl(content_location, start_position)** Sends specified URL to device
* **playfile(filepath, start_position, callback)** Serves specified file via HTTP to device
* **pause(callback)** shorthand for rate(0)
* **rate(rate)** Either 0.0 or 1.0, other values don't seem to work
* **volume(vol, callback)** Between 0.0 and 1.0
* **scrub(position, callback)** Seek to position (untested)
* **playback_info(cb)** duration, position, rate, playbackBufferEmpty, playbackBufferFull, playbackLikelyToKeepUp, readyToPlay, loadedTimeRanges, seekableTimeRanges

