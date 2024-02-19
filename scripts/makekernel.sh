#! /bin/bash

BRANCH=$1
CWD=$PWD
CPUS=$(($(nproc)))
KERNELDIR="KERNEL"
build_version=$(sed -n '3p' .config)
KERNELVERSION=$(echo "$build_version" | awk '{print $3}')
OUTDIR=KERNEL-${KERNELVERSION}
CONFIG_FILE=".config"
NEW_VALUE='CONFIG_LOCALVERSION="-byte4rr4y"'

git clone --depth=1 --branch $BRANCH https://github.com/raspberrypi/linux
cd linux
KERNEL=kernel_2712
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2712_defconfig
sed -i "s/^CONFIG_LOCALVERSION=.*$/$NEW_VALUE/" "$CONFIG_FILE"
mkdir -p "${KERNELDIR}"
make -j "${CPUS}" KERNELRELEASE="${KERNELVERSION}" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image.gz modules dtbs
env PATH=$PATH make KERNELRELEASE="${KERNELVERSION}" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH="${KERNELDIR}" modules_install
mkdir -p "${KERNELDIR}/boot/firmware/"
mkdir -p "${KERNELDIR}/lib/linux-image-${KERNELVERSION}/broadcom/"
mkdir -p "${KERNELDIR}/lib/linux-image-${KERNELVERSION}/overlays/"
echo "ffffffffffffffff B The real System.map is in the linux-image-<version>-dbg package" > "${KERNELDIR}/boot/System.map-${KERNELVERSION}"
cp .config "${KERNELDIR}/boot/config-${KERNELVERSION}"
cp arch/arm64/boot/Image.gz "${KERNELDIR}/boot/vmlinuz-${KERNELVERSION}"
cp arch/arm64/boot/Image.gz "${KERNELDIR}/boot/firmware/${OLDIMG}"
cp arch/arm64/boot/dts/broadcom/*.dtb "${KERNELDIR}/lib/linux-image-${KERNELVERSION}/broadcom/"
cp arch/arm64/boot/dts/overlays/*.dtb* "${KERNELDIR}/lib/linux-image-${KERNELVERSION}/overlays/"
cp arch/arm64/boot/dts/overlays/README "${KERNELDIR}/lib/linux-image-${KERNELVERSION}/overlays/"

# Erstellen des Zip-Archivs
ARCHIVE="kernel-$(sed -n 's|^.*\s\+\(\S\+\.\S\+\.\S\+\)\s\+Kernel Configuration$|\1|p' .config)$(sed -n 's|^CONFIG_LOCALVERSION=\"\(.*\)\"$|\1|p' .config).zip"
cd "${KERNELDIR}"
find lib -type l -exec rm {} \;
zip -q -r "${ARCHIVE}" *
cd -

mkdir $OUTDIR
mv "${KERNELDIR}/${ARCHIVE}" "${CWD}"
rm -rf $OUTDIR
cd $CWD

echo "1" > ${CWD}/config/kernel_status