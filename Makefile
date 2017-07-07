SHELL := /bin/bash

HD_SIZE=16

# Remove the local build staging area
clean:
	rm -rf *.img mini.iso initrd.gz linux ./boot/*

# Does the majority of the build process
build: download_netboot create_disk_image
	sudo xhyve -m 2G -c 1 -s 2:0,virtio-net \
		-s 3,ahci-cd,mini.iso -s 4,virtio-blk,hdd.img \
		-s 0:0,hostbridge -s 31,lpc -l com1,stdio \
		-f "kexec,linux,initrd.gz,earlyprintk=serial \
		console=ttyS0 acpi=off root=/dev/vda1 ro"

# Downloads the netboot images
download_netboot:
	wget http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/initrd.gz
	wget http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/netboot/ubuntu-installer/amd64/linux
	wget http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/netboot/mini.iso

# Creates a disk image with the requested size
create_disk_image:
	dd if=/dev/zero of=hdd.img bs=1g count=0 seek=$(HD_SIZE)

# Installs the /boot and hdd.img files to persistent storage, then
install: pre-install launchctl

preinstall:
	mkdir -p /Library/Containers/com.erianna.lxe/boot
	cp -R ./boot/* /Library/Containers/com.erianna.lxe/boot/
	cp ./boot.sh /Library/Containers/com.erianna.lxe
	cp hdd.img /Library/Containers/com.erianna.lxe

launchctl:
	if [ -f /Library/LaunchDaemons/xhyve.lxe.erianna.com.plist ]; then  \
		launchctl unload /Library/LaunchDaemons/xhyve.lxe.erianna.com.plist; \
	fi
	
	cp ./headless.sh /Library/Containers/com.erianna.lxe
	chmod a+x  /Library/Containers/com.erianna.lxe/headless.sh
	cp xhyve.lxe.erianna.com.plist /Library/LaunchDaemons/
	chown root /Library/LaunchDaemons/xhyve.lxe.erianna.com.plist
	launchctl load /Library/LaunchDaemons/xhyve.lxe.erianna.com.plist

# Uninstalls the image
uninstall:
	rm -rf /Library/Containers/com.erianna.lxe/boot
	launchctl unload -w /Library/LaunchDaemons/xhyve.lxe.erianna.com.plist
	rm -rf /Library/LaunchDaemons/xhyve.lxe.erianna.com.plist

