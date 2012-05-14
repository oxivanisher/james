#!/bin/bash

$(which mpc) volume 70
$(which mpc) play
sleep 600
$(which mpfade) 30 0
