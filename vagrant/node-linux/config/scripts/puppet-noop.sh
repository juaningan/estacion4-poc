#!/bin/bash
set -e
set -x
set -u

PUPPET_ENV=master

/usr/local/bin/fsconsul -addr="127.0.0.1:8500" -once=true controlrepo/${PUPPET_ENV}/controlrepo /etc/puppetlabs/code/environments/${PUPPET_ENV}/  || true
mv /etc/puppetlabs/code/environments/${PUPPET_ENV}/hiera.yaml /etc/puppetlabs/puppet/.
mv /etc/puppetlabs/code/environments/${PUPPET_ENV}/consul_kv.yaml /etc/puppetlabs/puppet/.
/opt/puppetlabs/puppet/bin/puppet apply /etc/puppetlabs/code/environments/${PUPPET_ENV}/manifests/site.pp --environment=${PUPPET_ENV} --noop
