#!/bin/bash

. ./test.cfg
nohup ./recordipcam.pl &>$outputDir/recordip.log &

