#1/bin/bash
set -e
set -x
set -u

env
/usr/local/bin/envconsul -sanitize -upcase -prefix configuration/common -prefix configuration/$HOSTNAME /vagrant/config/puppet.sh

