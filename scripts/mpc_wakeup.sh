#!/bin/bash

mpc volume 1
mpc clear
mpc load energy_rock
mpfade 10 60
date +"%A, %e. %B, %H:%M" | espeak
mpc volume 80
