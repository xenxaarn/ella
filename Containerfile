FROM quay.io/fedora/fedora-bootc:45

LABEL org.opencontainers.image.title="Ella" \
      org.opencontainers.image.description="Immutable Fedora bootc desktop with XFCE" \
      org.opencontainers.image.source="https://github.com/xenxaarn/ella" \
      org.opencontainers.image.licenses="MIT"

RUN dnf install -y --setopt=install_weak_deps=False \
    xfce4-session xfce4-panel xfce4-settings xfce4-terminal \
    xfdesktop xfwm4 xfconf xfce4-appfinder xfce4-power-manager \
    xfce4-notifyd xfce4-screenshooter xfce4-pulseaudio-plugin \
    mate-polkit dbus-x11 \
    thunar thunar-volman thunar-archive-plugin tumbler mousepad ristretto file-roller \
    xfce4-taskmanager xfce4-screensaver \
    gvfs gvfs-mtp gvfs-smb gvfs-fuse gnome-keyring gnome-keyring-pam \
    fwupd cups system-config-printer zram-generator-defaults \
    lightdm lightdm-gtk xorg-x11-server-Xorg \
    firefox mozilla-openh264 \
    celluloid mpv gparted smartmontools gnote \
    neovim btop fastfetch git curl wget \
    NetworkManager-wifi network-manager-applet bluez blueman power-profiles-daemon firewalld \
    pipewire pipewire-pulseaudio wireplumber flatpak distrobox podman fuse-libs \
    xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-xfce xdg-user-dirs xdg-utils \
    mesa-dri-drivers mesa-vulkan-drivers linux-firmware \
    rsms-inter-fonts jetbrains-mono-fonts-all google-noto-emoji-fonts \
    gcc gcc-c++ clang clang-tools-extra cmake ninja-build make gdb lldb valgrind \
    pkgconf-pkg-config openssl-devel \
    python3 python3-pip python3-devel \
    plank dconf gtk-update-icon-cache levien-inconsolata-fonts \
 && dnf clean all \
 && rm -rf /var/cache/* /var/log/* /var/lib/dnf /var/lib/rpm-state /run/dnf

ARG DOTFILES_REF=36831c5395d3ccd30ae9779e14e6c6beb6956c15
RUN git init /tmp/dots \
 && git -C /tmp/dots remote add origin https://github.com/xenxaarn/dotfiles \
 && git -C /tmp/dots fetch --depth 1 origin "${DOTFILES_REF}" \
 && git -C /tmp/dots checkout --detach FETCH_HEAD \
 && /tmp/dots/install.sh --system \
 && rm -rf /tmp/dots

RUN mkdir -p /etc/lightdm/lightdm.conf.d \
 && printf '[Seat:*]\ngreeter-session=lightdm-gtk-greeter\n' \
      > /etc/lightdm/lightdm.conf.d/50-ella.conf

RUN mkdir -p /etc/flatpak/remotes.d \
 && curl -fsSL https://dl.flathub.org/repo/flathub.flatpakrepo -o /etc/flatpak/remotes.d/flathub.flatpakrepo

RUN printf 'export EDITOR=nvim\nexport VISUAL=nvim\n' > /etc/profile.d/editor.sh

RUN systemctl enable lightdm NetworkManager bluetooth power-profiles-daemon firewalld cups.socket \
 && systemctl set-default graphical.target \
 && systemctl mask systemd-remount-fs.service bootc-fetch-apply-updates.timer

RUN sed -i 's/^NAME=.*/NAME="Ella"/; s/^PRETTY_NAME=.*/PRETTY_NAME="Ella"/; s/^DEFAULT_HOSTNAME=.*/DEFAULT_HOSTNAME="ella"/' /usr/lib/os-release

RUN mkdir -p /etc/yum.repos.d \
 && for f in /usr/share/dnf5/repos.d/*.repo; do \
      [ -e "/etc/yum.repos.d/$(basename "$f")" ] || cp "$f" /etc/yum.repos.d/; \
    done

COPY cosign.pub /etc/pki/containers/cosign.pub
COPY policy.json /etc/containers/policy.json
COPY ella-sigstore.yaml /etc/containers/registries.d/ella.yaml

RUN bootc container lint
