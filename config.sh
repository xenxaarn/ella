#!/bin/bash

set -euxo pipefail

test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

: "${kiwi_iname:=Ella}"
echo "Configure image: [$kiwi_iname]..."

/usr/libexec/ella-branding

DOTFILES_REF=36831c5395d3ccd30ae9779e14e6c6beb6956c15
git init -q /tmp/dots
git -C /tmp/dots remote add origin https://github.com/xenxaarn/dotfiles
git -C /tmp/dots fetch -q --depth 1 origin "$DOTFILES_REF"
git -C /tmp/dots checkout -q --detach FETCH_HEAD
/tmp/dots/install.sh --system
rm -rf /tmp/dots

# Flathub remote.
mkdir -p /etc/flatpak/remotes.d
curl -fsSL https://dl.flathub.org/repo/flathub.flatpakrepo -o /etc/flatpak/remotes.d/flathub.flatpakrepo

systemctl enable \
  lightdm \
  NetworkManager \
  bluetooth \
  power-profiles-daemon \
  firewalld \
  cups.socket \
  ella-branding.service \
  ella-branding.path
systemctl set-default graphical.target

rm -f /etc/machine-id
echo 'uninitialized' >/etc/machine-id
rm -f /var/lib/systemd/random-seed

echo "GRUB_DEFAULT=saved" >>/etc/default/grub
echo "GRUB_DISABLE_SUBMENU=true" >>/etc/default/grub
echo "GRUB_DISABLE_RECOVERY=true" >>/etc/default/grub

passwd -d root
passwd -l root

touch /var/lib/rpm/.updated
touch /var/lib/rpm/.rpmdb

# Anaconda stays installed (the live boot needs it) but never shows a launcher.
for f in /usr/share/applications/liveinst.desktop /usr/share/applications/org.fedoraproject.AnacondaInstaller.desktop; do
  if [ -f "$f" ]; then
    sed -i "/^NoDisplay=/d; /^\[Desktop Entry\]/a NoDisplay=true" "$f"
  fi
done

chmod 0755 /usr/bin/ella-install
echo "Ella image configuration complete"
