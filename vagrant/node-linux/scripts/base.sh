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

# Install deps
apt-get install -y unzip

# Install Consul
CONSUL_VERSION='0.8.1'
wget -q "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" -O consul.zip
unzip -o consul.zip -d /usr/local/bin
rm -f consul.zip
chmod 0755 /usr/local/bin/consul
chown root:root /usr/local/bin/consul

# Configure Consul
mkdir -p /etc/consul.d
chmod 0755 /etc/consul.d
cp -v ${CONFIG_DIR}/consul/default.json /etc/consul.d/.
cp -v ${CONFIG_DIR}/consul/watches.json /etc/consul.d/.
cp -v ${CONFIG_DIR}/consul/consul.service /etc/systemd/system/.
systemctl daemon-reload
systemctl enable consul.service

# Install fsconsul
wget -q "https://bintray.com/cimpress-mcp/Go/download_file?file_path=v0.6.5%2Flinux-amd64%2Ffsconsul" -O /usr/local/bin/fsconsul
chmod 0755 /usr/local/bin/fsconsul
chown root:root /usr/local/bin/fsconsul

# Install sifter
SIFTER_VERSION='0.7'
wget -q "https://github.com/darron/sifter/releases/download/v${SIFTER_VERSION}/sifter-${SIFTER_VERSION}-linux-amd64.gz" -O - | gunzip -c > /usr/local/bin/sifter
chmod 0755 /usr/local/bin/sifter
chown root:root /usr/local/bin/sifter

# Install custom scripts
cp -v ${CONFIG_DIR}/scripts/* /usr/local/bin/.
chmod +x /usr/local/bin/*.sh

systemctl start consul.service
