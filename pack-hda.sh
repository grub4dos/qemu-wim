#!/bin/sh

# Define starting sector for the partition
START_SECTOR=2048

# Create a 16MB blank disk image
dd if=/dev/zero of=hda.img bs=1M count=12

# Create an MBR partition table on hda.img
parted hda.img mklabel msdos

# Create a primary FAT32 partition from sector START_SECTOR to the end of the disk
# "100%" indicates the end of the disk
parted -s hda.img mkpart primary fat16 ${START_SECTOR}s 100%

# Attach the entire disk image to a loop device with partition scanning enabled (-P)
LOOPDEV=$(losetup -f --show -P hda.img)

# Format the first partition with FAT32 filesystem so that it gets the correct BPB
mkfs.vfat -F 16 ${LOOPDEV}p1

# Create a temporary mount point and mount the partition
mkdir -p /mnt/hda_img
mount ${LOOPDEV}p1 /mnt/hda_img

# Copy all files from the hda/ directory into the mounted partition
cp -r hda/* /mnt/hda_img/

# Unmount the partition and detach the loop device
umount /mnt/hda_img
losetup -d $LOOPDEV
