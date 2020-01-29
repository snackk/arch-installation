# arch-installation
<p align="center">
 <img src="https://www.archlinux.org/static/logos/archlinux-logo-dark-1200dpi.b42bd35d5916.png" alt="alt text" width="600" height="200">
 </p>

[![Build Status](https://travis-ci.org/snackk/arch-installation.svg?branch=master)](https://travis-ci.org/snackk/arch-installation) [![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Overview

This is a tool that I've built to help ease the process of installing arch-linux distro. It's meant to install the base arch-linux system, and then apply my drivers, config, Desktop-Environment upon it. Settings could be changed to meet your desire, edit the snackk.conf file.

First of all you should download and burn the latest arch-linux image, that you can find under releases.
As an alternative, you can build the image yourself, look under [Customizing image](#image) to see how.

The installation is divided in several stages:

* **arch-installation** - *(needed)* Installs arch-linux base system.
* **arch-configuration** - *(needed)* Sets up hostname, keyboard, language, timezone, root password and installs some dependencies along with grub.
* **environment-setup** - *(needed)* Sets up a graphical environment with Deepin.
* **snackk-setup** - *(Optional)* Installs [arch-config-files](https://github.com/snackk/arch-config-files).

* **toshiba-s50-b131-setup** - *(Warning)* Specific hardware configuration for this particular laptop.
* **xiaomi-notebook-pro-setup** - *(Warning)* Specific hardware configuration for this particular laptop.


### <a name="image"></a> Customizing image

Install the required tools and download the latest arch-linux image from the official page:
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

* ### <a name="internet"></a> Connect to the internet

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

 * Next some hardware specific dependencies and drivers (Password may be needed here):
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
