#!/bin/bash

set -e
set -x
set -u

export DEBIAN_FRONTEND=noninteractive

# Install puppet agent
wget https://apt.puppetlabs.com/puppetlabs-release-pc1-yakkety.deb
dpkg -i puppetlabs-release-pc1-yakkety.deb
apt-get update
apt-get install -y puppet-agent

# Install fsconsul
wget -q "https://bintray.com/cimpress-mcp/Go/download_file?file_path=v0.6.4%2Flinux-amd64%2Ffsconsul" -O /usr/local/bin/fsconsul
chmod 0755 /usr/local/bin/fsconsul
chown root:root /usr/local/bin/fsconsul

cp -v ${CONFIG_DIR}/fsconsul/fsconsul.service /etc/systemd/system/.
systemctl daemon-reload
#systemctl enable fsconsul.service
#systemctl start fsconsul.service
