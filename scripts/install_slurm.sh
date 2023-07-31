# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
touch /var/log/install.txt

mkdir ~/slurm
cd ~/slurm
git clone https://salsa.debian.org/hpc-team/slurm-wlm.git
cd slurm-wlm
cp debian/control debian/control.bkp
cp debian/rules debian/rules.bkp

sudo apt install debhelper libmunge-dev libncurses-dev po-debconf python3 libgtk2.0-dev  \
default-libmysqlclient-dev  libpam0g-dev  libperl-dev  chrpath  libpam0g-dev  \
liblua5.1-0-dev  libhwloc-dev  dh-exec  librrd-dev   libipmimonitoring-dev  \
 hdf5-helpers  libfreeipmi-dev  libhdf5-dev  man2html  libcurl4-openssl-dev  \
 libpmix-dev  libhttp-parser-dev  libyaml-dev  libjson-c-dev  libjwt-dev \
  liblz4-dev  bash-completion  libdbus-1-dev  librdkafka-dev -y

sed -i "/^\ librocm-smi-dev/d" debian/control
sed -i "s/^\ librdkafka-dev\,/\ librdkafka-dev/g" debian/control

sed -i "/^Package:\ slurm-wlm-rsmi-plugin*\ plugin.$/ s|^|#|; /^Package:\ slurm-wlm-rsmi-plugin/, /\ plugin.$/ s|^|#|" debian/control

sed -i "/dh_strip\ -pslurm-wlm-rsmi-plugin/d" debian/rules

dpkg-buildpackage -rfakeroot -b -d 2>&1 >> install.lo
cd ../

sudo apt install -y -f ./slurmctld_23.02.3-2_amd64.deb -f ./slurmd_23.02.3-2_amd64.deb slurmctld_23.02.3-2_amd64.deb slurm-client_23.02.3-2_amd64.deb slurm-wlm-basic-plugins_23.02.3-2_amd64.deb ./slurm-wlm-mysql-plugin_23.02.3-2_amd64.deb

mkdir /var/spool/slurmd
chown slurm: /var/spool/slurmd
chmod 755 /var/spool/slurmd
mkdir -p /var/log/slurm

# touch /var/log/slurmd.log
# chown slurm: /var/log/slurmd.log
chown slurm: /var/spool/slurm
chown slurm: /var/log/slurm

sed -i "s/#SlurmdLogFile=/SlurmdLogFile=\/var\/log\/slurm\/slurmd.log/" /etc/slurm/slurm.conf
sed -i "s/#SlurmctldLogFile=/SlurmctldLogFile=\/var\/log\/slurm\/slurmctld.log/" /etc/slurm/slurm.conf

# Add hostname -s to /etc/hosts
echo "127.0.0.1 $(hostname -s)" >> /etc/hosts

# TODO: Do we need both?
sudo systemctl start slurmctld
sudo systemctl start slurmd
sudo systemctl enable slurmd
sudo systemctl enable slurmctld

# If these crash restart; it crashes sometimes
sed -i '/\[Service]/a Restart=always\nRestartSec=5' /usr/lib/systemd/system/slurmctld.service
sed -i '/\[Service]/a Restart=always\nRestartSec=5' /usr/lib/systemd/system/slurmd.service
systemctl daemon-reload