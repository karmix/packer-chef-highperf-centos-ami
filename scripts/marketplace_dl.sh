#!/bin/bash -x
set -o errexit -o nounset -o pipefail

# Construct URLs from environment variables passed by packer.
DL_BASEURL="https://packages.chef.io/files"
DL_CHANNEL="stable"

if [ "${URL_CHEFSERVER:+set}" != set ] ; then
  URL_CHEFSERVER=${DL_BASEURL}/${DL_CHANNEL}/chef-server/${VER_CHEFSERVER}/el/7/chef-server-core-${VER_CHEFSERVER}-1.el7.x86_64.rpm
fi

if [ "${URL_MANAGE:+set}" != set ] ; then
  URL_MANAGE=${DL_BASEURL}/${DL_CHANNEL}/chef-manage/${VER_MANAGE}/el/7/chef-manage-${VER_MANAGE}-1.el7.x86_64.rpm
fi

if [ "${URL_PJS:+set}" != set ] ; then
  URL_PJS=${DL_BASEURL}/${DL_CHANNEL}/opscode-push-jobs-server/${VER_PJS}/el/7/opscode-push-jobs-server-${VER_PJS}-1.el7.x86_64.rpm
fi

if [ "${URL_SUPERMARKET:+set}" != set ] ; then
  URL_SUPERMARKET=${DL_BASEURL}/${DL_CHANNEL}/supermarket/${VER_SUPERMARKET}/el/7/supermarket-${VER_SUPERMARKET}-1.el7.x86_64.rpm
fi

if [ "${URL_AUTOMATE:+set}" != set ] ; then
  URL_AUTOMATE=https://packages.chef.io/files/current/automate/latest/chef-automate_linux_amd64.zip
fi

mkdir -p /var/cache/marketplace
pushd /var/cache/marketplace

echo ">>> Writing out a timestamp"
echo "This package cache was generated for AWS Native Chef Stack marketplace ${VER_MARKETPLACE} on $(date)" > TIMESTAMP

echo ">>> Caching install scripts"
install --mode=755 /tmp/chef_server_setup.sh ./main.sh
rm -f /tmp/chef_server_setup.sh

echo ">>> Downloading and caching packages"
curl -s -OL "$URL_CHEFSERVER"
ln -s "${URL_CHEFSERVER##*/}" chef-server-core.rpm

curl -s -OL "$URL_MANAGE"
ln -s "${URL_MANAGE##*/}" chef-manage.rpm

curl -s -OL "$URL_PJS"
ln -s "${URL_PJS##*/}" push-jobs-server.rpm

curl -s -OL "$URL_SUPERMARKET"
ln -s "${URL_SUPERMARKET##*/}" supermarket.rpm

curl -s "$URL_AUTOMATE" | gunzip - > chef-automate && chmod +x chef-automate
./chef-automate airgap bundle create chef-automate.bundle

echo ">>> Installing nightly snapshot script"
curl -s -L https://raw.githubusercontent.com/CaseyLabs/aws-ec2-ebs-automatic-snapshot-bash/master/ebs-snapshot.sh -o /usr/local/bin/ebs-snapshot.sh
chmod 755 /usr/local/bin/ebs-snapshot.sh

echo ">>> Installing aws-signing-proxy command"
curl -s -L https://github.com/chef-customers/aws-signing-proxy/releases/download/v0.5.0/aws-signing-proxy -o /usr/local/bin/aws-signing-proxy
chmod 755 /usr/local/bin/aws-signing-proxy

echo ">>> Installing other necessary packages"
yum install -y perl perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https perl-Digest-SHA zip unzip python-pip

echo ">>> Installing monitoring tools"
# Filebeat
curl -s -OL https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.6.6-x86_64.rpm

# awslogs
curl -s -OL https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py
chmod +x awslogs-agent-setup.py

popd

# Cloudwatch monitoring
mkdir -p /opt/cloudwatch_monitoring
pushd /opt/cloudwatch_monitoring
curl -s -OL http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip
unzip CloudWatchMonitoringScripts-1.2.1.zip
rm -f CloudWatchMonitoringScripts-1.2.1.zip
popd
