# rpi5-image-builder

You must resize rootfs manually, i work on auto-grow-root at the moment

You simply can use 'raspi-config'

# This script builds a SD-Card image for raspberry pi 5 as it follows:
    - Building the rootfile system inside a docker container.
    - Compiling a Custom RPi-Kernel and installing it.
    - Put everything together to creeate a bootable SD-Card image.

# Installation:
----------------------
    git clone https://github.com/byte4RR4Y/rpi5-image-builder
    sudo ./install.sh
----------------------

# To build an SD-Card image follow the instructions after:
    sudo ./build.sh

You will find your image in the output folder.

# Adding custom packages to install
    -If you want to add packages to install, append it to config/app-packages/pkg.txt
     instead of modifying the Dockerfile

# Other Desktops be added soon...
---------------------------------------------------
 # Contact to the developer: byte4rr4y@gmail.com #
---------------------------------------------------


# Required Host system:
  - Debian/amd64 (bullseye, bookworm, MX 21 and MX23 are tested)

# What you can build?
DEBIAN:
  - Testing
  - Experimental
  - Trixie
  - Sid
  - Bookworm
  - Bullseye

Kernel from 3.16.x - 6.8.x

Currently supported desktops:
  - XFCE (Not yet tested, report any issues)
