## [1-2] adding platform, repository and suite
ARG SUITE
FROM --platform=linux/arm64/v8 arm64v8/debian:${SUITE}

# [3-11] Define Variables
ARG DESKTOP
ARG ADDITIONAL
ARG USERNAME
ARG PASSWORD

ENV DESKTOP=$DESKTOP
ENV ADDITIONAL=$ADDITIONAL
ENV USERNAME=$USERNAME
ENV PASSWORD=$PASSWORD
ENV DEBIAN_FRONTEND=noninteractive

## [12-13] define shell and adding non-free sources to the apt repository
RUN sed -i '/^Components:/ s/$/ contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources
SHELL ["/bin/bash", "-c"]

## [14] upgrading packages, installing apt-utils, dialog and aptitude
RUN apt update -y && apt upgrade -y && apt install -y apt-utils dialog aptitude

## [15] install the basic debian system
RUN aptitude install -y '?priority(required)' '?priority(important)' '?priority(standard)' nano wget curl sudo gpg gpg-agent network-manager firmware-brcm80211

## [16-21] adding the raspberrypi repository
RUN wget http://archive.raspberrypi.org/debian/raspberrypi.gpg.key
RUN gpg --no-default-keyring --keyring ./raspberrypi_keyring.gpg --import raspberrypi.gpg.key
RUN gpg --no-default-keyring --keyring ./raspberrypi_keyring.gpg --export > ./raspberrypi.gpg
RUN mv ./raspberrypi.gpg /etc/apt/trusted.gpg.d/
RUN rm raspberrypi*
RUN echo "deb [signed-by=/etc/apt/trusted.gpg.d/raspberrypi.gpg] http://archive.raspberrypi.org/debian/ bookworm main untested" > /etc/apt/sources.list.d/raspberrypi.list

## [22] update repositories
RUN aptitude update -y

## [23] installing raspberrypi tools and configuration
RUN aptitude install -y raspi-config raspi-firmware raspi-utils rpi-eeprom rpi-eeprom-images

## [24-25] installing additional apt packages from apt-packages/pkg.txt
COPY config/apt-packages/pkg.txt /root
RUN xargs apt install -y < /root/pkg.txt

## [26] installing the desktop environment
RUN if [[ $DESKTOP == "xfce" ]]; then \
    touch /etc/firstboot && aptitude install -y xfce4 xorg lightdm network-manager-gnome \
        && if [[ $ADDITIONAL == "yes" ]]; then \
    aptitude install -y xfce4-goodies darkcold-gtk-theme firefox-esr synaptic pavucontrol pulseaudio pulseaudio-module-bluetooth vlc gimp menulibre xfce4-power-manager xfce4-settings alsa-utils \
        ; fi \
    ; fi
## [27] Creating rc.local to reconfigure lightdm and xfce on first boot and reboot into desktop

RUN echo "#! /bin/bash" > /etc/rc.local && \
    echo "" >> /etc/rc.local && \
    echo "if [ -e /etc/firstboot ]; then" >> /etc/rc.local && \
    echo "	hostnamectl set-hostname rpi5" >> /etc/rc.local && \
    echo "	chmod u+s /usr/bin/sudo" >> /etc/rc.local && \
    echo "	dpkg-reconfigure lightdm" >> /etc/rc.local && \
    echo "	dpkg-reconfigure xorg" >> /etc/rc.local && \
    echo "	dpkg-reconfigure xinit" >> /etc/rc.local && \
    echo "	dpkg-reconfigure xfce4" >> /etc/rc.local && \
    echo "	rm /etc/firstboot" >> /etc/rc.local && \
    echo "	reboot" >> /etc/rc.local && \
    echo "fi" >> /etc/rc.local && \
    echo "" >> /etc/rc.local && \
    echo "exit 0" >> /etc/rc.local

## [28] make /etc/rc.local executable
RUN chmod +x /etc/rc.local


## [29] Create a sudo user
RUN useradd -m -s /bin/bash "$USERNAME" \
    && echo "$USERNAME":"$PASSWORD" | chpasswd \
    && usermod -aG sudo "$USERNAME"

## [30] Creating the firmware folder
RUN mkdir -p /boot/firmware

## [31] Installing auto grow rootfilesystem on firstboot
RUN aptitude install -y initramfs-tools

## [32] Set SU-Bit for sudo
RUN chmod u+s /usr/bin/sudo

## [33] install auto grow root on firstboot
RUN aptitude install -y cloud-initramfs-growroot

## [34] make directory for kernel installation files
RUN mkdir /customkernel

## [35] create firstboot file for first boot setup
RUN touch /etc/firstboot

