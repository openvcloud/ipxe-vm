# IPXE VM build scripts
Build scripts for vm image that processes ipxe scripts

The purpose of the resulting VM image is simulate an IPXE a like boot system for a vm.
The url for the IPXE script can be passed to the VM via cloud-init in the user-data.
Currently it is only possible to pass the cloud-init via a CD-ROM image.

## Building

The image building requires mkinitcpio from ArchLinux and the following packages:
- syslinux
- e2fsprogs
- util-linux (losetup)
- parted
- busybox
- coreutils (dd)

Just run builder.sh as ROOT. Root is required to be able to use losetup and parted.

After running the build script you will find under build the following files:
- image.raw (the actually vm image)
- vmlinux-linux (kernel that is inside the image)
- initramfs-linux.img (initramfs used inside the image)


## How it works

The image that gets build from this script will boot up a minimal initramfs, this initramfs will attempt to mount the cloud-init cdrom and search for a `ipxe` line in the userdata once it is found it will parse lines starting with `initrd` and `chain` it will download the urls passed on those lines and execute `kexec` with this kernel and optionally the initrd pass the kerel params passed to the `chain` command.
