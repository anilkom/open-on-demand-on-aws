# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
sudo apt install sssd sssd-ldap oddjob-mkhomedir oddjob -y -q

sed -e '/PasswordAuthentication no/ s/^#*/#/' -i /etc/ssh/sshd_config
sed -i '/#PasswordAuthentication yes/s/^#//g' /etc/ssh/sshd_config
sudo systemctl restart sshd