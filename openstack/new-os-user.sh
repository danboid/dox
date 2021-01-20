#!/bin/bash
# A script to create new a Openstack user, project, router and subnet.
# Define the tenant (user) and source your OS admin rc file before running.
# The target domain must exist and a Member role within it must already be created.
set -eux

tenant=abc123

domain=astronomy
password=$(pwgen 12 1)
external_network=ext_net

openstack project create --domain ${domain} ${tenant}
openstack user create --domain ${domain} --password ${password} ${tenant}
echo ${password} > ${tenant}-password.txt
openstack role add --project ${tenant} --user ${tenant} --user-domain ${domain} Member
security_group_id=$(openstack security group list --project ${tenant} | sed -n 4p | awk '{ print $2 }')
openstack security group rule create ${security_group_id} --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0

function get_id() {
    $@ | grep " id" | awk '{ print $4 }'
}


ext_net_id=$(openstack network list  | grep tenant | awk '{ print $2 }')

if openstack router list | grep -q " ${tenant}_router "; then
  router_id=$(openstack router list | grep " ${tenant}_router " | awk '{ print $2 }')
else
  echo "Creating a new router for tenant"
  router_id=$(get_id openstack router create --project ${tenant} ${tenant}_router)
fi

echo "Wiring tenant router to the outside world"
openstack router set ${tenant}_router --external-gateway $external_network

echo "Creating tenant network if required"
if ! openstack network list | grep -q " ${tenant}_admin_net "; then

 openstack network create \
   --project ${tenant} \
   ${tenant}_admin_net

   # neutron net-update --dns-domain ${tenant}.cloud.karyon.io. ${tenant}_admin_net
   # openstack network set --dns-domain ${tenant}.cloud.karyon.io ${tenant}_admin_net

fi
if ! openstack subnet list | grep -q " ${tenant}_admin_subnet "; then
   openstack subnet create \
     --project ${tenant} \
     --network ${tenant}_admin_net \
     --subnet-range 10.5.0.0/16 \
     --dns-nameserver 1.1.1.1 \
     --dhcp \
     --allocation-pool start=10.5.0.2,end=10.5.20.255 \
     ${tenant}_admin_subnet
   openstack router add subnet ${tenant}_router ${tenant}_admin_subnet
fi

