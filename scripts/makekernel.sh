#! /bin/bash

BRANCH=$1
CWD=$PWD
OUTDIR=${CWD}
CPUS=$(($(nproc)))

git clone --depth=1 --branch $BRANCH https://github.com/raspberrypi/linux
cd linux

make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2712_defconfig

KERNELDIR="KERNEL-${BRANCH}"
mkdir -p "${KERNELDIR}"

make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2712_defconfig
sed -i "s/^CONFIG_LOCALVERSION=.*$/CONFIG_LOCALVERSION="-byte4rr4y"/" ".config"
BUILD="$(sed -n 's|^.*\s\+\(\S\+\.\S\+\.\S\+\)\s\+Kernel Configuration$|\1|p' .config)"

      make -j ${CPUS} KERNELRELEASE="${BUILD}" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image.gz modules dtbs
      env PATH=$PATH make KERNELRELEASE="${BUILD}" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=${KERNELDIR} modules_install
      mkdir -p "${KERNELDIR}/boot/firmware/"
      mkdir -p "${KERNELDIR}/lib/linux-image-${BUILD}/broadcom/"
      mkdir -p "${KERNELDIR}/lib/linux-image-${BUILD}/overlays/"
      echo "ffffffffffffffff B The real System.map is in the linux-image-<version>-dbg package" > "${KERNELDIR}/boot/System.map-${BUILD}"
      cp .config "${KERNELDIR}/boot/config-${BUILD}"
      cp arch/arm64/boot/Image.gz "${KERNELDIR}/boot/vmlinuz-${BUILD}"
      cp arch/arm64/boot/Image.gz "${KERNELDIR}/boot/firmware/kernel_2712.img"
      cp arch/arm64/boot/dts/broadcom/*.dtb "${KERNELDIR}/lib/linux-image-${BUILD}/broadcom/"
      cp arch/arm64/boot/dts/overlays/*.dtb* "${KERNELDIR}/lib/linux-image-${BUILD}/overlays/"
      cp arch/arm64/boot/dts/overlays/README "${KERNELDIR}/lib/linux-image-${BUILD}/overlays/"
   
  ARCHIVE="kernel-$(sed -n 's|^.*\s\+\(\S\+\.\S\+\.\S\+\)\s\+Kernel Configuration$|\1|p' .config)$(sed -n 's|^CONFIG_LOCALVERSION=\"\(.*\)\"$|\1|p' .config).zip"
  cd "${KERNELDIR}"
  find lib -type l -exec rm {} \;
  zip -q -r "${ARCHIVE}" *
  if [ "${OUTDIR}" != "" ]; then
    if [ "${OUTDIR: -1}" != "/" ]; then
      OUTDIR+="/"
    fi
  else
    if [ "${REALUSER}" = "root" ]; then
      OUTDIR="/root/"
    else
      OUTDIR="/home/${REALUSER}/"
    fi
  fi
chown "${REALUSER}:${REALUSER}" "${ARCHIVE}"
cd ${CWD}/linux
mv "${KERNELDIR}/${ARCHIVE}" "${OUTDIR}"
rm -rf "${KERNELDIR}"
cd ${CWD}
rm -rf linux

echo "1" > ${CWD}/config/kernel_status