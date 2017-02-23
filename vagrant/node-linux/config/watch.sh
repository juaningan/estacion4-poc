#1/bin/bash
set -e
set -x
set -u

consul watch -type=event -name=puppet /usr/local/bin/envpuppet.sh

/usr/local/bin/envconsul -sanitize -upcase -prefix config/common -prefix config/$HOSTNAME "/usr/local/bin/fsconsul -addr="127.0.0.1:8500" -once=true controlrepo/${PUPPET_ENV}/controlrepo /etc/puppetlabs/code/environments/${PUPPET_ENV}/ /opt/puppetlabs/puppet/bin/puppet apply /etc/puppetlabs/code/environments/${PUPPET_ENV}/manifests/site.pp --environment=${PUPPET_ENV}

