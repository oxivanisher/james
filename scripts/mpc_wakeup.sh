#!/bin/bash

$(which mpc) volume 1
$(which mpc) clear
$(which mpc) load http://stream.srg-ssr.ch/drs1/mp3_128.m3u
$(which mpfade) 10 60
date +"%A, %e. %B, %H:%M" | espeak
$(which mpc) volume 80
