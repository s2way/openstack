tag 'computeNode'
#

hostsfile_entry node['openstack']['nodes']['controller']['ipaddress'] do
    hostname node['openstack']['nodes']['controller']['hostname']
    action :create_if_missing
end

hostsfile_entry '10.0.0.41' do
    hostname 'block1'
    action :create_if_missing
end

apt_repository 'cloudarchive-mitaka' do
    uri 'http://ubuntu-cloud.archive.canonical.com/ubuntu'
    distribution 'trusty-updates/mitaka'
    components ['main']
    action [:add]
end

package 'nova-compute' do
    options '--force-yes'
end

file '/etc/nova/nova.conf' do
    content "
[DEFAULT]
dhcpbridge_flagfile=/etc/nova/nova.conf
dhcpbridge=/usr/bin/nova-dhcpbridge
logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/var/lock/nova
force_dhcp_release=True
libvirt_use_virtio_for_bridges=True
verbose=True
ec2_private_dns_show_ip=True
api_paste_config=/etc/nova/api-paste.ini
enabled_apis=ec2,osapi_compute,metadata
rpc_backend=rabbit
auth_strategy=keystone
my_ip=#{node['openstack']['nodes']['controller']['ipaddress']}
use_neutron=True
firewall_driver=nova.virt.firewall.NoopFirewallDriver

[oslo_messaging_rabbit]
rabbit_host=controller
rabbit_userid=openstack
rabbit_password=secret

[cinder]
os_region_name=RegionOne

[keystone_authtoken]
auth_uri=http://controller:5000
auth_url=http://controller:35357
memcached_servers=controller:11211
auth_type=password
project_domain_name=default
user_domain_name=default
project_name=service
username=nova
password=secret

[vnc]
enabled=True
vncserver_listen=0.0.0.0
vncserver_proxyclient_address=$my_ip
novncproxy_base_url=http://controller:6080/vnc_auto.html

[oslo_concurrency]
lock_path=/var/lib/nova/tmp

[neutron]
url=http://controller:9696
auth_url=http://controller:35357
auth_type=password
project_domain_name=default
user_domain_name=default
region_name=RegionOne
project_name=service
username=neutron
password=secret
"
end

file '/etc/nova/nova-compute.conf' do
    content '[DEFAULT]
compute_driver=libvirt.LibvirtDriver
[libvirt]
virt_type=qemu
'
end


# NEUTRON

package 'neutron-linuxbridge-agent' do
    options '--force-yes'
end

file '/etc/neutron/neutron.conf' do
    content "
[DEFAULT]
core_plugin=ml2
rpc_backend=rabbit
auth_strategy=keystone

[agent]

root_helper=sudo /usr/bin/neutron-rootwrap /etc/neutron/rootwrap.conf

[cors]

[cors.subdomain]

[database]

connection=sqlite:////var/lib/neutron/neutron.sqlite

[keystone_authtoken]
auth_uri=http://controller:5000
auth_url=http://controller:35357
memcached_servers=controller:11211
auth_type=password
project_domain_name=default
user_domain_name=default
project_name=service
username=#{node['openstack']['neutron']['username']}
password=#{node['openstack']['neutron']['password']}

[matchmaker_redis]

[nova]

[oslo_concurrency]

[oslo_messaging_amqp]

[oslo_messaging_notifications]

[oslo_messaging_rabbit]
rabbit_host=controller
rabbit_userid=openstack
rabbit_password=secret

[oslo_policy]

[quotas]

[ssl]
"
end

file '/etc/neutron/plugins/ml2/linuxbridge_agent.ini' do
    content '
[DEFAULT]

[agent]

[linux_bridge]
physical_interface_mappings=provider:eth1

[securitygroup]
enable_security_group=True
firewall_driver=neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

[vxlan]
enable_vxlan=True
local_ip=10.0.0.31
l2_population=True
'
end
