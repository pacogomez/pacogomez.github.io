#!/bin/bash

# Hostname of CoreOS Instance
CORE_OS_HOSTNAME=coreos1

# IP Address of CoreOS Instance
CORE_OS_IP_ADDRESS=192.168.109.2

# IP Address of the gateway
CORE_OS_IP_GW=192.168.109.1

# Username to enable on CoreOS Instance
CORE_OS_USERNAME=vcauser

CORE_OS_AUTHORIZED_KEYS='AAAAB3NzaC1yc2EAAAADAQABAAABAQC3ZGXfIeoNoAiKBTeEQqiF...'

# Name of the CoreOS Cloud Config ISO
CLOUD_CONFIG_ISO=${CORE_OS_HOSTNAME}-config.iso

TMP_CLOUD_CONFIG_DIR=/tmp/new-drive

echo "Build Cloud Config Settings ..."
mkdir -p ${TMP_CLOUD_CONFIG_DIR}/openstack/latest

cat > ${TMP_CLOUD_CONFIG_DIR}/openstack/latest/user_data << __CLOUD_CONFIG__
#cloud-config

hostname: ${CORE_OS_HOSTNAME}

write_files: 
  - path: /etc/systemd/network/static.network 
    permissions: 0644 
    content: | 
      [Match] 
      Name=en*
      [Network] 
      Address=${CORE_OS_IP_ADDRESS}/24 
      Gateway=${CORE_OS_IP_GW}
      DNS=8.8.8.8
      
coreos:
  units:
    - name: systemd-networkd.service
      command: start
      
users:
  - name: ${CORE_OS_USERNAME}
    primary-group: wheel
    groups:
      - sudo
      - docker
    ssh-authorized-keys:
      - ssh-rsa ${CORE_OS_AUTHORIZED_KEYS}
      
__CLOUD_CONFIG__

echo "Creating Cloud Config ISO ..."
mkisofs -R -V config-2 -o ${CLOUD_CONFIG_ISO} ${TMP_CLOUD_CONFIG_DIR}
