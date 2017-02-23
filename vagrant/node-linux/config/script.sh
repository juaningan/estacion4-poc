#1/bin/bash
set -e
set -x
set -u

PUPPET_ENV=master

/usr/local/bin/fsconsul -addr="192.168.50.2:8500" -once=true controlrepo/${PUPPET_ENV}/controlrepo /etc/puppetlabs/code/environments/${PUPPET_ENV}/

/opt/puppetlabs/puppet/bin/puppet apply /etc/puppetlabs/code/environments/${PUPPET_ENV}/manifests/site.pp --environment=${PUPPET_ENV}
