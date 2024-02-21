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
RUN aptitude install -y '?priority(required)' '?priority(important)' '?priority(standard)' nano wget curl sudo gpg gpg-agent network-manager zip unzip e2fsprogs apparmor kmod

## [16-24] adding the raspberrypi repository
RUN wget http://archive.raspberrypi.org/debian/raspberrypi.gpg.key
RUN gpg --no-default-keyring --keyring ./raspberrypi_keyring.gpg --import raspberrypi.gpg.key
RUN gpg --no-default-keyring --keyring ./raspberrypi_keyring.gpg --export > ./raspberrypi.gpg
RUN mv ./raspberrypi.gpg /etc/apt/trusted.gpg.d/
RUN rm raspberrypi*
RUN echo "deb [signed-by=/etc/apt/trusted.gpg.d/raspberrypi.gpg] http://archive.raspberrypi.org/debian/ bookworm main untested" > /etc/apt/sources.list.d/raspberrypi.list
RUN echo "Package: firmware-brcm80211" >> /etc/apt/preferences.d/wifi-driver
RUN echo "Pin: origin archive.raspberrypi.org" >> /etc/apt/preferences.d/wifi-driver
RUN echo "Pin-Priority: 999" >> /etc/apt/preferences.d/wifi-driver && \
	echo "/dev/mmcblk0p1  /boot/firmware  vfat  rw  0  2" >> /etc/fstab


## [25] update repositories
RUN aptitude update -y

## [26] installing raspberrypi tools and configuration
RUN aptitude install -y raspi-config raspi-firmware raspi-utils rpi-eeprom rpi-eeprom-images firmware-brcm80211 git bc bison flex libssl-dev make

## [27-28] installing additional apt packages from apt-packages/pkg.txt
COPY config/apt-packages/pkg.txt /root
RUN xargs apt install -y < /root/pkg.txt

## [29] installing the desktop environment
RUN if [[ $DESKTOP == "xfce" ]]; then \
    touch /etc/firstboot && aptitude install -y xfce4 xorg lightdm network-manager-gnome \
        && if [[ $ADDITIONAL == "yes" ]]; then \
    aptitude install -y xfce4-goodies darkcold-gtk-theme firefox-esr synaptic pavucontrol pulseaudio pulseaudio-module-bluetooth vlc gimp menulibre xfce4-power-manager xfce4-settings alsa-utils \
        ; fi \
    ; fi
## [30] Copy rc.local to update /etc/fstab and reconfigure lightdm and xfce on first boot and reboot into desktop
COPY scripts/rc.local /etc/

## [31] make /etc/rc.local executable
RUN chmod +x /etc/rc.local

## [32] Create a sudo user
RUN useradd -m -s /bin/bash "$USERNAME" \
    && echo "$USERNAME":"$PASSWORD" | chpasswd \
    && usermod -aG sudo "$USERNAME"

## [33] Creating the firmware folder
RUN mkdir -p /boot/firmware

## [34] Installing auto grow rootfilesystem on firstboot
RUN aptitude install -y initramfs-tools

## [35] Set SU-Bit for sudo
RUN chmod u+s /usr/bin/sudo

## [36] install auto grow root on firstboot
RUN aptitude install -y cloud-initramfs-growroot

## [37] create firstboot file for first boot setup
RUN touch /etc/firstboot

## [38] change owner of USERNAME's home
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# [38] save size of root filesystem in rootfs_size.txt, needed for creating the rootfs image
RUN echo $(($(du -s -m --exclude=/proc / | awk '{print $1}'))) > /rootfs_size.txt

RUN echo "toor\ntoor" | passwd root
