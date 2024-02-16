#!/bin/bash

if [ $(id -u) -ne 0 ]; then
  errexit "You must be root!"
fi

if [ $# -ne 1 ]; then
  echo "Usage: $0 <zip_file>"
  exit
fi

ARCHIVE="$1"
VERSION="$2"
ARCHIVE="$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' <<< "${ARCHIVE}")"

unzip -o "${ARCHIVE}" -d /
update-initramfs -c -v -k "${VERSION}"
