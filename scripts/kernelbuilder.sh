#!/bin/bash

BRANCH=$1
CWD=$PWD
OUTDIR="${CWD}/files/kernel/"
ARCHIVE="kernel.zip"
KERNEL=kernel_2712
BUILD="$(sed -n 's|^.*\s\+\(\S\+\.\S\+\.\S\+\)\s\+Kernel Configuration$|\1|p' .config)-byte4rr4y-rpi-2712"
DSTDIR="$(mktemp --directory)"

echo "${BUILD}" > ${CWD}/files/kernel/kernel_version

git clone --depth=1 --branch "${BRANCH}" https://github.com/raspberrypi/linux $DSTDIR
cd $DSTDIR
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2712_defconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j $(($(nproc))) Image modules dtbs
env PATH=$PATH make KERNELRELEASE="${BUILD}" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=${DSTDIR} modules_install

mkdir -p "${DSTDIR}/boot/firmware/"
mkdir -p "${DSTDIR}/lib/linux-image-${BUILD}/broadcom/"
mkdir -p "${DSTDIR}/lib/linux-image-${BUILD}/overlays/"
echo "System.map you'll find in linux-image-$(sed -n 's|^.*\s\+\(\S\+\.\S\+\.\S\+\)\s\+Kernel Configuration$|\1|p' .config)-dbg" > "${DSTDIR}/boot/System.map-${BUILD}"
cp .config "${DSTDIR}/boot/config-${BUILD}"
cp arch/arm64/boot/Image "${DSTDIR}/boot/vmlinuz-${BUILD}"
cp arch/arm64/boot/Image "${DSTDIR}/boot/firmware/${KERNEL}.img"
cp arch/arm64/boot/dts/broadcom/*.dtb "${DSTDIR}/lib/linux-image-${BUILD}/broadcom/"
cp arch/arm64/boot/dts/overlays/*.dtb* "${DSTDIR}/lib/linux-image-${BUILD}/overlays/"
cp arch/arm64/boot/dts/overlays/README "${DSTDIR}/lib/linux-image-${BUILD}/overlays/"

# Kopieren und Zippen aller Dateien
cd "${DSTDIR}"
find lib -type l -exec rm {} \;
zip -q -r "${ARCHIVE}" *

chown "${SUDO_USER}:${SUDO_USER}" "${ARCHIVE}"
cd "${CWD}"
mv "${DSTDIR}/${ARCHIVE}" "${OUTDIR}"
rm -r "${DSTDIR}"

