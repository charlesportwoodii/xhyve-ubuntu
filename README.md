# Xyhve Ubuntu 16.04 Server

This tool assists in installing Ubuntu 16.04 Server on macOS using xhyve. Installation is done using a NetBoot image to reduce complexity

## Installation

1. Install [xhyve](https://github.com/mist64/xhyve) for macOS
```
$ brew update
$ brew install --HEAD xhyve
```

2. Run `make build`, and go through the normal Ubuntu installation process. Make sure you install GRUB to the MBR.
```
$ make build
```

> Avoid resize your terminal while you're going through the installer.

3. When you get to `Installation Complete`, select `Go Back`, then `Execute Shell`. Before we can boot into our image we need to first recovery initrd and the kernel. Inside the Virtual Machine, fetch the current IP Address, then use nc to start the transfer.

```
# Display the current IP Address
$ /sbin/ip addr show enp0s2

# Transfer the kernel and initrd files to the host
# This command will wait for the host to recieve the files before completing
tar cf - boot/initrd.img-* boot/vmlinuz-* | nc -l -p 1234
```

Open a new terminal window, then run the following command to recieve the files. Adjust `<ipaddress>` as necessary.

```
nc <ipaddress> 1234 | tar xf -
```

4. Type `exit` inside the Virtual Machine then complete the installation. Ubuntu will then shutdown.

5. You can now boot into your VM by running the `./boot.sh` command
```
$ chmod a+x ./boot.sh
$ ./boot.sh
```

The VM will be backgrounded via screen. To access it, run `screen -r` to re-attach the session.

## Post Installation

Once you've booted into your VM, there's a few additional commands you can run to make life easier.

1. Install Avahi to add name lookup support.
```
sudo apt-get install avahi-daemon
```

2. Install XTerm to allow window resizing
```
sudo apt-get install -y xterm
echo "export TERM=xterm-256color" >> $HOME/.bashrc
```

> Note that if the machine is booted headlessly you will need to SSH into the machine to access it.

3. If you want the VM to start on boot, you run `make install`, which will persist the disk image, and create a launchctl setting. Note that if launchctl is used, the image will be launched in headless mode, meaning that unless SSH is setup on the server you will not be able to access the tty.

## Maintenance

When updating the kernel inside the VM, you'll need to copy the `initrd.img` and `vmlinuz` images back to the host. These files will be located in either `/` or `/boot`.

## Stopping the VM.

There are several different ways to shut down the vm.

1. From the host, kill the `xhyve` process.
```
sudo kill $(ps aux | grep xhyve | grep root | head -n 1 | awk '{ print $2 }')
```

2. Shutdown the guest from within the guest.