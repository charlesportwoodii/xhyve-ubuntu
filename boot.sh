#!/bin/sh

cd "$(dirname $0)"

MEM="-m 2G"
SMP="-c 2"

PROGRAM="$(which xhyve)"
KERNEL="$(ls boot/vmlinuz-* | sort -u | tail -1)"
INITRD="$(ls boot/initrd.img-* | sort -u | tail -1)"
CMDLINE="earlyprintk=serial console=ttyS0 acpi=off root=/dev/vda1 ro"

NET="-s 2:0,virtio-net"
IMG_HDD="-s 4,virtio-blk,./hdd.img"
PCI_DEV="-s 0:0,hostbridge"
LPC_DEV=" -s 31,lpc -l com1,stdio"

PROCESS_COUNT=$(ps aux | grep -i xhyve | wc -l)
if [ $PROCESS_COUNT -gt 1 ]; then
    echo "XHYVE VM is already running";
else
    screen -dmS lxe sudo ${PROGRAM} ${MEM} ${SMP} ${PCI_DEV} ${LPC_DEV} ${NET} ${IMG_HDD} -f "kexec,${KERNEL},${INITRD},${CMDLINE}"
fi