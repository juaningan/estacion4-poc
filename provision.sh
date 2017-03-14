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
CONSUL_VERSION='0.7.5'
wget -q "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" -O consul.zip
unzip -o consul.zip -d /usr/local/bin
rm -f consul.zip
chmod 0755 /usr/local/bin/consul
chown root:root /usr/local/bin/consul

# Configure Consul
mkdir -p /etc/consul.d
chmod 0755 /etc/consul.d
cat << EOF > /etc/consul.d/default.json
{
  "start_join": ["192.168.100.59"],
  "bind_addr": "{{ GetAllInterfaces | include \"network\" \"192.168.100.0/24\"  | sort \"size,address\" | attr \"address\" }}"
}
EOF
cat << EOF > /etc/consul.d/watches.json
{
  "watches": [
    {
      "type": "event",
      "name": "puppet-apply",
      "handler": "sifter run -e '/usr/local/bin/puppet.sh'"
    },
    {
      "type": "event",
      "name": "puppet-noop",
      "handler": "sifter run -e '/usr/local/bin/puppet-noop.sh'"
    }
  ]
}
EOF
cat << EOF > /etc/systemd/system/consul.service
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
ExecStart=/usr/local/bin/consul agent -dev -config-dir="/etc/consul.d"

[Install]
WantedBy=multi-user.target
EOF
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
cat << 'EOF' > /usr/local/bin/puppet.sh
#!/bin/bash
set -e
set -x
set -u

PUPPET_ENV=master

/usr/local/bin/fsconsul -addr="127.0.0.1:8500" -once=true controlrepo/${PUPPET_ENV}/controlrepo /etc/puppetlabs/code/environments/${PUPPET_ENV}/  || true
mv /etc/puppetlabs/code/environments/${PUPPET_ENV}/hiera.yaml /etc/puppetlabs/puppet/.
echo "reports = consul_kv" > /etc/puppetlabs/puppet/puppet.conf
mv /etc/puppetlabs/code/environments/${PUPPET_ENV}/consul_kv.yaml /etc/puppetlabs/puppet/.
/opt/puppetlabs/puppet/bin/puppet apply /etc/puppetlabs/code/environments/${PUPPET_ENV}/manifests/site.pp --environment=${PUPPET_ENV}
EOF
cat << 'EOF' > /usr/local/bin/puppet-noop.sh
#!/bin/bash
set -e
set -x
set -u

PUPPET_ENV=master

/usr/local/bin/fsconsul -addr="127.0.0.1:8500" -once=true controlrepo/${PUPPET_ENV}/controlrepo /etc/puppetlabs/code/environments/${PUPPET_ENV}/  || true
mv /etc/puppetlabs/code/environments/${PUPPET_ENV}/hiera.yaml /etc/puppetlabs/puppet/.
echo "reports = consul_kv" > /etc/puppetlabs/puppet/puppet.conf
mv /etc/puppetlabs/code/environments/${PUPPET_ENV}/consul_kv.yaml /etc/puppetlabs/puppet/.
/opt/puppetlabs/puppet/bin/puppet apply /etc/puppetlabs/code/environments/${PUPPET_ENV}/manifests/site.pp --environment=${PUPPET_ENV} --noop
EOF
chmod +x /usr/local/bin/*.sh

systemctl start consul.service
