#  Ella

***Ella*** is an image based, Immutable Linux Distro built using `bootc` & the filesystem is **readonly**. Ella uses XFCE with LightDM instead of GNOME Shell/GDM.

![images](images/home.png)

### Update & Maintain
- status and available updates
` bootc status `
- upgrade to latest version
`sudo bootc upgrade && sudo systemctl reboot`
- rollback to a previous version `sudo bootc rollback && systemctl reboot`
- enable temporary writable /usr `sudo bootc usr-overlay`

### Installing apps
- Use GNOME Software or `flatpak` for Flathub apps.
- AppImages and Distrobox are alternatives.

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
