#!/bin/bash

. ./shed.cfg
nohup ./recordipcam.pl shed.cfg &>$outputDir/recordip.log &

#. ./sittingroom.cfg
#nohup ./recordipcam.pl sittingroom.cfg &>$outputDir/recordip.log &

