# Xyhve Ubuntu 16.04 Server

This tool assists in installing Ubuntu 16.04 Server on macOS using xhyve. Installation is done using a NetBoot image to reduce complexity

## Installation

1. Install [xhyve](https://github.com/mist64/xhyve) for macOS
```
$ brew update
$ brew install --HEAD xhyve
```

2. Run `./build.sh`, and go through the normal Ubuntu installation process. Make sure you install GRUB to the MBR.
```
$ chmod a+x build.sh
$ ./build.sh
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

## Headless Boot

The VM can be booted in headless mode by running the following command

```
$ ./boot.sh headless
```

> Note that if the machine is booted headlessly you will need to SSH into the machine to access it.

## Maintenance

When updating the kernel inside the VM, you'll need to copy the `initrd.img` and `vmlinuz` images back to the host. These files will be located in either `/` or `/boot`.