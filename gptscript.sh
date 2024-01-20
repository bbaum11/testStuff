#!/bin/bash

# This script performs basic system hardening for CentOS 7.

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Update the system
yum update -y

# Disable unnecessary services
systemctl disable avahi-daemon
systemctl disable postfix

# Remove unnecessary packages
yum remove -y sendmail telnet

# Set password policies
sed -i 's/PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sed -i 's/PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs
sed -i 's/PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs

# Configure firewall (adjust ports as needed)
firewall-cmd --zone=public --remove-service=dhcpv6-client --permanent
firewall-cmd --zone=public --remove-service=ipp --permanent
firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --reload

# Enable SELinux
sed -i 's/SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config

# Configure SSH
sed -i 's/PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

# Disable unused network protocols
echo "install dccp /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install sctp /bin/true" >> /etc/modprobe.d/CIS.conf

# Set umask to 027
echo "umask 027" >> /etc/profile

# Enable auditd
systemctl enable auditd
systemctl start auditd

# Disable unused filesystems
echo "install cramfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install freevxfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install jffs2 /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install hfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install hfsplus /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install squashfs /bin/true" >> /etc/modprobe.d/CIS.conf
echo "install udf /bin/true" >> /etc/modprobe.d/CIS.conf

# Harden sysctl settings
echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.conf
sysctl -p

# Display completion message
echo "CentOS 7 Hardening Completed."
