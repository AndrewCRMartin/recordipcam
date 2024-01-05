#!/bin/bash

. ./test.cfg.shed
nohup ./recordipcam.pl test.cfg.shed &>$outputDir/recordip.log &

#. ./test.cfg.sittingroom
#nohup ./recordipcam.pl test.cfg.sittingroom &>$outputDir/recordip.log &

