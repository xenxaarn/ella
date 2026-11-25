#  Ella

***Ella*** is a Fedora desktop with XFCE and LightDM themed Tokyo Night & is built with *KIWI NG*. 

![images](images/home.png)

### Install
Boot the ISO. The live desktop opens the terminal installer (UEFI only, LUKS2 + Btrfs). It copies the live image to disk, so no network is needed. .

### Build the ISO
```
sudo ./build.sh                 # in a privileged Fedora 45 container (Podman/Docker)
sudo ./build.sh --native        # directly on a Fedora 45 host
```

### Update & Maintain
`sudo dnf upgrade --refresh && sudo systemctl reboot`

### Installing apps
- Use GNOME Software or `flatpak` for Flathub apps.
- `dnf install` for Fedora packages.

### Apps Pre-installed 

- firefox
- Thunar (file manager)
- XFCE settings
- XFCE terminal
- Ristretto (image viewer)
- Celluloid (media player)
- GParted and smartmontools
- Gnote
- Gnome Software
- neovim
- btop
- fastfetch

### Dev tools Pre-installed
 - gcc
- gcc-c++
- clang 
- clang-tools-extra
- cmake
-  ninja-build
- make 
- gdb 
- lldb 
- valgrind 
- git
- curl
- pkgconf-pkg-config
- openssl-devel 
- python3
- python3-pip 
- python3-devel 

### License
[MIT](LICENSE)
