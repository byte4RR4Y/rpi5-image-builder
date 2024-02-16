#! /bin/bash

BRANCH=$1

# Clone des Kernel-Repositorys
git clone --depth=1 --branch $BRANCH https://github.com/raspberrypi/linux

# Wechseln in das Kernel-Verzeichnis
cd linux

# Definition des Kernel-Namens
KERNEL=kernel_2712
MAX_CPUS=$(($(nproc) - 1))

# Konfiguration und Erstellung des Kernels
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2712_defconfig
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j $MAX_CPUS Image modules dtbs

# Erstellen des temporären Verzeichnisses für das Zip-Archiv
TEMP_DIR=$(mktemp -d)

# Kopieren der erstellten Dateien in das temporäre Verzeichnis
cp arch/arm64/boot/Image $TEMP_DIR/$KERNEL.img
cp arch/arm64/boot/dts/broadcom/*.dtb $TEMP_DIR/
cp .config $TEMP_DIR/kernel.config
cp Module.symvers $TEMP_DIR/

# Erstellen des Zip-Archivs
ZIP_NAME=$KERNEL-$(date +%Y%m%d-%H%M%S).zip
zip -r ../files/kernel/${ZIP_NAME} $TEMP_DIR/*

# Reinigung
rm -rf $TEMP_DIR
cd ..
echo "1" > config/kernel_status
