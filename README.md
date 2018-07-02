# Arch installation

## Overview

Before anything, a customized image of arch-linux must be built, for the scripts to be on the bootable image of arch-linux. After that, the installation is divided in several stages:

* **arch-installation** - *(needed)* Installs arch-linux base system.
* **arch-configuration** - *(needed)* Sets up hostname, keyboard, language, timezone, root password and installs some dependencies along with grub, to boot the newly installed system.
* **environment-setup** - *(needed)* Sets up a graphical environment with Deepin.
* **snackk-setup** - *(Optional)* Installs [arch-config-files](https://github.com/snackk/arch-config-files).

* **toshiba-s50-b131-setup** - *(Warning)* Specific hardware configuration for this particular laptop.
* **xiaomi-notebook-pro-setup** - *(Warning)* Specific hardware configuration for this particular laptop.


## Customizing image

To run the makefile install the required tools, and also download the latest arch-linux image:
```sh
$ sudo pacman -S squashfs-tools cdrtools
```

After that you need to clone this repo:
```sh
$ git https://github.com/snackk/arch-installation && cd arch-installation
```

Now run the Makefile:
```sh
$ make ISO=~/Downloads/archlinux-2017.08.01-dual.iso
```

Final iso will be available inside the repository directory. 
Use dd or whatever tool you use to burn it somewhere.

## Installation

* Boot the customized image.

* Change the keyboard layout.
```sh
$ loadkeys pt-latin9
```

* ### <a name="internet"></a> Connect to the internet.

Wireless:
```sh
$ wifi-menu
```
or Wired:
```sh
$ dhcpcd
 ```
 
* Change *snackk.conf* to your own configs. 

* Run arch-installation.
```sh
$ ./arch-installation.sh
```

 * After it shutdown, turn it back on (Default login is *root* and *password*).
 Connect to the [internet](#internet) again and then run:
```sh
$ cd /
$ ./environment-setup.sh
```

 * Next some hardware configs (Password may be needed here):
```sh
$ ./toshiba-s50-b131-setup.sh
$ reboot
```

 * [arch-config-files](https://github.com/snackk/arch-config-files) are packaged with this image, to install run this:
```sh
$ ./snackk-setup.sh
```

* You're good to go!

* Don't forget to change your password later on.
 
 ## Problems
 
 If you can't run the scripts:
```sh
$ chmod +x *.sh
```

## Acknowledgements

The script to make a custom image of arch-linux is based on this project [Anarchy](https://github.com/magnunleno/Anarchy), they made a huge effort on making it happen, I've just made a few tweaks and changes so it would run on the newest arch-linux image.

## Disclaimer

I am not responsible for any damage to your machine. Run at your own risk.
  
  Written by [@snackk](https://github.com/snackk)
