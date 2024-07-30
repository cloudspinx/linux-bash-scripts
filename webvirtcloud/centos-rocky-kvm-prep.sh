#!/bin/bash
# Update package list
sudo apt update

# Install KVM packages
sudo dnf install -y libvirt qemu-kvm virt-install virt-top libguestfs-tools guestfs-tools
sudo dnf -y install epel-release
sudo dnf -y install bridge-utils
sudo systemctl enable --now libvirtd

# Install other dependencies
sudo dnf install python3-libguestfs supervisor cyrus-sasl-md5 -y

# Configure libvirt to allow connections from WebvirtCloud
sudo sed -i 's/: gssapi/: digest-md5/g' /etc/sasl2/libvirt.conf
sudo sed -i 's/#sasldb_path/sasldb_path/g' /etc/sasl2/libvirt.conf

sudo sed -i 's/#listen_tls/listen_tls/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#listen_tcp/listen_tcp/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#auth_tcp/auth_tcp/g'     /etc/libvirt/libvirtd.conf

# Allow VNC connections from WebvirtCloud instance (you can replace 0.0.0.0) with something else.
sudo sed -i 's/#[ ]*vnc_listen.*/vnc_listen = "0.0.0.0"/g' /etc/libvirt/qemu.conf
sudo sed -i 's/#[ ]*spice_listen.*/spice_listen = "0.0.0.0"/g' /etc/libvirt/qemu.conf

# Configure gstfsd
wget https://raw.githubusercontent.com/retspen/webvirtcloud/master/conf/daemon/gstfsd
chmod +x gstfsd
sudo mv gstfsd /usr/local/bin/gstfsd 
wget https://raw.githubusercontent.com/retspen/webvirtcloud/master/conf/supervisor/gstfsd.conf
chmod +x gstfsd.conf
sudo mv gstfsd.conf /etc/supervisord.d/gstfsd.ini

# Restart services (libvirtd & supervisor services)
sudo systemctl enable libvirtd supervisord
sudo systemctl restart libvirtd supervisord
sudo systemctl status libvirtd supervisord
