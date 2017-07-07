#!/bin/bash

wget http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/initrd.gz
wget http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/linux
wget http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/netboot/mini.iso
dd if=/dev/zero of=hdd.img bs=1g count=0 seek=16

sudo xhyve -m 2G -c 1 -s 2:0,virtio-net \
  -s 3,ahci-cd,mini.iso -s 4,virtio-blk,hdd.img \
  -s 0:0,hostbridge -s 31,lpc -l com1,stdio \
  -f "kexec,linux,initrd.gz,earlyprintk=serial \
  console=ttyS0 acpi=off root=/dev/vda1 ro"