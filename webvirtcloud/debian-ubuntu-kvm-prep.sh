#!/bin/bash
# Update package list
sudo apt update

# Install KVM packages
sudo apt install libvirt-daemon qemu-kvm \
libvirt-daemon-system virtinst libosinfo-bin \
libguestfs-tools bridge-utils -y

# Install other dependencies
sudo apt install sasl2-bin python3-guestfs supervisor -y

# Configure libvirt to allow connections from WebvirtCloud
sudo sed -i 's/: gssapi/: digest-md5/g' /etc/sasl2/libvirt.conf
sudo sed -i 's/#sasldb_path/sasldb_path/g' /etc/sasl2/libvirt.conf

sudo sed -i 's/#listen_tls/listen_tls/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#listen_tcp/listen_tcp/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#auth_tcp/auth_tcp/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#auth_unix_rw = "polkit"/auth_unix_rw = "none"/g' /etc/libvirt/libvirtd.conf

# Allow VNC connections from WebvirtCloud instance (you can replace 0.0.0.0) with something else.
sudo sed -i 's/#[ ]*vnc_listen.*/vnc_listen = "0.0.0.0"/g' /etc/libvirt/qemu.conf
sudo sed -i 's/#[ ]*spice_listen.*/spice_listen = "0.0.0.0"/g' /etc/libvirt/qemu.conf

# Configure gstfsd
wget https://raw.githubusercontent.com/retspen/webvirtcloud/master/conf/daemon/gstfsd
chmod +x gstfsd
sudo mv gstfsd /usr/local/bin/gstfsd 
wget https://raw.githubusercontent.com/retspen/webvirtcloud/master/conf/supervisor/gstfsd.conf
chmod +x gstfsd.conf
sudo mv gstfsd.conf /etc/supervisor/conf.d/gstfsd.conf

# Restart services (libvirtd & supervisor services)
sudo systemctl enable libvirtd supervisor
sudo systemctl restart libvirtd supervisor
sudo systemctl status libvirtd supervisor
