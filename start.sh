#!/bin/bash

. ./shed.cfg
nohup ./recordipcam.pl shed.cfg &>$outputDir/recordip.log &

. ./garden.cfg
nohup ./recordipcam.pl garden.cfg &>$outputDir/recordip.log &

. ./sittingroom.cfg
nohup ./recordipcam.pl sittingroom.cfg &>$outputDir/recordip.log &

. ./upstairsrear.cfg
nohup ./recordipcam.pl upstairsrear.cfg &>$outputDir/recordip.log &

