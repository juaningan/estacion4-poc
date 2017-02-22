#!/bin/bash

set -e
set -x
set -u

export DEBIAN_FRONTEND=noninteractive

# Install deps
apt-get install -y unzip

# Install Consul
CONSUL_VERSION='0.7.5'
wget -q "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" -O consul.zip
unzip -o consul.zip -d /usr/local/bin
rm -f consul.zip
chmod 0755 /usr/local/bin/consul
chown root:root /usr/local/bin/consul

# Configure Consul
mkdir -p /etc/consul.d
chmod 0755 /etc/consul.d
cp -v ${CONFIG_DIR}/consul/consul.service /etc/systemd/system/.
systemctl daemon-reload
systemctl enable consul.service
systemctl start consul.service

# Install git2consul
apt-get install -y npm nodejs-legacy
npm install -g git2consul
cp -v ${CONFIG_DIR}/git2consul/git2consul.service /etc/systemd/system/.
cp -v ${CONFIG_DIR}/git2consul/git2consul.json /etc/.
systemctl daemon-reload
systemctl enable git2consul.service
systemctl start git2consul.service
