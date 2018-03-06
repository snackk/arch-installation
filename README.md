# arch-installation

### Credits

This script is based on this project [Anarchy](https://github.com/magnunleno/Anarchy), they made a huge effort on customizing the arch-linux iso, I've just made a few tweaks so it would run on the newest arch-linux image.

### About

Before anything, a customized image of arch-linux must be built, for the scripts to be on the bootable image of arch-linux. After that, the installation is divided in 3 stages:
* **arch-installation** - Installs arch-linux.
* **arch-configuration** - Sets up hostname, keyboard, language, timezone, root password and installs dependencies and grub.
* **environment-setup** - Sets up a graphical environment with Deepin.
* **snackk-setup** - *(Optional)* After arch-linux has been installed, populates arch with a bunch of configs that i use for my own personal use. You can find those configs here [arch-config-Files](https://github.com/snackk/arch-config-files).
* **toshiba-s50-b131-setup** - *(Optional)* Specific hardware configuration for my laptop.

### Customizing image

To run the makefile you'll need this tool's installed:
```sh
$ sudo pacman -S squashfs-tools cdrtools
```
After that just run the following code:
```sh
$ make ISO=~/Downloads/archlinux-2017.08.01-dual.iso
```
Final iso will be available inside this repository directory. Use dd or whatever tool you use to make it bootable.

### Installation (change snackk.conf to suit your needs)

* Boot the customized image.
* Change the keyboard layout.
```sh
$ loadkeys pt-latin9
```
* Connect to the internet.
Wireless:
```sh
$ wifi-menu
```
or Wired:
```sh
$ dhcpcd
```
* Run arch-installation.
```sh
$ ./arch-installation.sh
```
 * After it shutdown, turn it back on. Connect to the internet again and then run:
```sh
$ ./environment-setup.sh
```
 * Next some hardware configs (Password needed here):
```sh
$ ./toshiba-s50-b131-setup.sh
$ reboot
```
 * To install zsh and custom arch-config-files run:
```sh
$ ./snackk-setup.sh
```
* You're good to go :D
 
 ### Problems
 If you can't run the scripts:
```sh
$ chmod +x *.sh
```
### Disclaimer
I am not responsible for any damage to your machine. Run at your own risk
  
  Written by Diogo Santos.
