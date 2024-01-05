recordipcam V0.2
================

(c) Andrew C.R. Martin, 2023-24
-------------------------------

`recordipcam` is a program for using ffmpeg to record from an IP
camera. Currently it has only been tested on Wansview cameras.

The program records segments of video (of a specified length -
typically 5 minutes) and deletes videos after a specified time
(typically 30 days). It also checks that the data files are being
updated and tries to restart if they aren't. Eventually it will have
an option to send an email when there is a problem.

Configuration File
------------------

The configuration file is in `keyword=value` format with no spaces
either side of the `=` sign (see`template.cfg`).

It requires you to specify the following:

- `outputDir`      - The directory where you will store the recordings
- `username`       - The username for accessing the camera
- `password`       - The password for accessing the camera
- `ip`             - The IP address of the camera. Alternatively you can
                   specify the MAC address
- `mac`            - The MAC address of the camera. This is better if IP
                   addresses are automatically allocated by DHCP
- `port`           - The port for RTSP access to the camera (normally 554)
- `path`           - The path for the camera's feed. For Wansview cameras,
                   this is `/live/ch0`
- `segmentLength`  - The length of each recording segment in seconds
                   (e.g. 300 for 5 minutes)
- `keepRecordings` - The number of days to keep a recording (e.g. 30)
- `url`            - The URL for accessing the camera. This can be
                   specified completely or by reference to the values
                   set above.

The URL can be the full URL such as:

```
url=rtsp://username:password@192.168.0.200:554/live/ch0
```

or you can use the other variables you set earlier:

```
url=rtsp://${username}:${password}${IP}:${port}${path}
```

If you are giving a MAC address for the camera instead of an IP
address, then you must specify the IP address as `[IP]` - this acts as
a placeholder into which the IP address will be placed by the program
once it has determined the IP associated with the MAC address.
```
url=rtsp://username:password@[IP]:554/live/ch0
```
or
```
url=rtsp://${username}:${password}@[IP]:${port}${path}
```

Running the program
-------------------

Once you have created your config file, you run the program specifying
the config file as a parameter to the program. e.g.:
```
./recordipcam.pl recordipcam.cfg
```
If the config file is called `recordipcam.cfg` then you don't need to
specify the name.

Normally you would run the program such that it will detach and run
in the background with something like:
```
nohup ./recordipcam.pl recordip.cfg &>logdir/recordip.log &
```
See `start.sh` for examples where the directory for the log file is
picked up from the config file.