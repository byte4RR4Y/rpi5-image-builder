#!/bin/bash

ARCHIVE="$1"
ARCHIVE="$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' <<< "${ARCHIVE}")"

unzip -o "${ARCHIVE}" -d / || errexit "unzip ${ARCHIVE} failed"
BUILD="$(unzip -l "${ARCHIVE}" boot/vmlinuz-* | sed -n 's|^.*boot/vmlinuz-\(.*\)$|\1|p')"
update-initramfs -c -v -k "${BUILD}"
echo "Kernel installation completed"
