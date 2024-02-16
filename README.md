## rpi5-image-builder


# Installation:
----------------------
    git clone https://github.com/byte4RR4Y/rpi5-image-builder
    sudo ./install.sh
----------------------

# To build an SD-Card image follow the instructions after:
    sudo ./build.sh

# Adding custom packages to install
    -If you want to add packages to install, append it to config/app-packages/pkg.txt
     instead of modifying the Dockerfile

# Other Desktops be added soon...
---------------------------------------------------
 # Contact to the developer: byte4rr4y@gmail.com #
---------------------------------------------------


# Required Host system:
  - amd64
  - Debian (bullseye and bookworm are tested)

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
  - XFCE
