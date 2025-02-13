#!/bin/bash


if [ -z "$1" ]; then
  echo "Usage: $0 </dev/sdcard_device>"
  echo "Example: $0 /dev/mmcblk0"
  exit 1
fi

DEVICE=$1
IMAGE_NAME=${2:-"prolific-image"}

if [[ $DEVICE != /dev/* ]]; then
  echo "Error: Device must start with /dev/"
  exit 1
fi

DEVICE_NAME=${DEVICE##*/}

set -x

# Generate the image for the SD card
sudo ./build/tmp/deploy/images/stm32mp13-disco/scripts/create_sdcard_from_flashlayout.sh ./build/tmp/deploy/images/stm32mp13-disco/flashlayout_${IMAGE_NAME}/extensible/FlashLayout_sdcard_stm32mp135f-dk-extensible.tsv

# Unmount all partitions associated with the SD card.
sudo umount "$(lsblk --list | grep "$DEVICE_NAME" | grep part | gawk '{ print $7 }' | tr '\n' ' ')"

# Place image on SD Card
sudo dd if=./build/tmp/deploy/images/stm32mp13-disco/flashlayout_${IMAGE_NAME}/extensible/../../FlashLayout_sdcard_stm32mp135f-dk-extensible.raw of=/dev/mmcblk0 bs=8M conv=fdatasync status=progress

sudo sgdisk /dev/mmcblk0 -p
sudo sgdisk /dev/mmcblk0 -v
