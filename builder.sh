#!/bin/bash
set -e
if [[ "$UID" != 0 ]]; then
    echo "Root required for building"
    exit 1
fi
repodir=$(dirname $0)
builddir="${repodir}/build"
imagefile="${repodir}/build/image.raw"
mountpath="/tmp/$RANDOM"

mkdir -p "${builddir}"
mkdir -p "${mountpath}"
mkinitcpio -c "${repodir}/mkinitcpio-ipxe.conf" -g "${builddir}/initramfs.img"
truncate -s 100M "${imagefile}"
losetup -f "${imagefile}"
device=$(losetup -a | grep "${imagefile}" | cut -f 1 -d :)
parted "$device" -s mklabel msdos
parted "$device" -s mkpart primary ext2 1MiB 99MiB
parted "$device" -s set 1 boot on
mkfs.ext2 -F "${device}p1"
mount "${device}p1" "${mountpath}"
cp /boot/vmlinuz-linux "${mountpath}"
cp "${builddir}/initramfs.img" "${mountpath}"
echo "Installing bootloader"
mkdir -p "${mountpath}/syslinux"
cp -a "$repodir/initcpio/"* /etc/initcpio/
cp /usr/lib/syslinux/bios/ldlinux.c32 "${mountpath}/syslinux"
extlinux --install "${mountpath}/syslinux"
cp "${repodir}/syslinux.cfg" "${mountpath}/syslinux/"
umount "${mountpath}"
rmdir $mountpath
dd bs=440 count=1 conv=notrunc if=/usr/lib/syslinux/bios/mbr.bin of="$device"
losetup -d "$device"
