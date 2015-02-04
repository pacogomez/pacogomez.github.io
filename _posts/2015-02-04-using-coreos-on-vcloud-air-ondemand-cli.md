---
layout: post
title: Using CoreOS on vCloud Air On Demand
comments: true
permalink: /coreos-vcloud-air-on-demand
---

[CoreOS](https://coreos.com) is a popular Linux distribution for applications that use [Docker Containers](https://www.docker.com). The following article describes the steps to install CoreOS on [vCloud Air On Demand](https://github.com/vmware/vca-cli). The use of [vCloud Air Command Line Interface](https://github.com/vmware/vca-cli) makes the process easier to document and more convenient to follow. 

The guide assumes the following pre-requisites:

* An account on [vCloud Air On Demand](http://vcloud.vmware.com), with a virtual data center created in one of the available instances (you can sign up and get $300 credit)
* [vCloud Air Command Line Interface](https://github.com/vmware/vca-cli), vca-cli (version 0.9)
* [ovftool](https://www.vmware.com/support/developer/ovf/)

In a nutshell, the process consists of the following steps:

1. download the CoreOS OVA to the local computer and upload it to vCloud Air as a template
2. create a CoreOS VM based on the template
3. customize a local cloud-config file, create an ISO file and upload it to vCloud Air
4. attach the ISO to the VM, boot it up and let CoreOS configure itself
5. configure the edge gateway to allow SSH access to the CoreOS VM

The transfer of the OVA template is a one-time operation. The template can be used to instantiate multiple VMs. 

To install vca-cli version 0.9, run the command below. Please note that the documentation for this release (0.9) has not been updated yet. The documentation on the GitHub site is for the previous version (0.5).

    
    pip install vca-cli==0.9
    

Log in to the vCloud Air account and list the instances available:

    vca login email@company.com --password supersecretpassword
    
    vca instance
    Available instances for user 'email@company.com' in 'default' profile:
    | Instance Id                          | Region                            | Plan Id                              |
    |--------------------------------------+-----------------------------------+--------------------------------------|
    | fbf278f0-065d-4028-96d4-6ece56789751 | us-virginia-1-4.vchs.vmware.com   | feda2919-32cb-4efd-a4e5-c5953733df33 |
    | c40ba6b4-c158-49fb-b164-5c66f90344fa | us-california-1-3.vchs.vmware.com | 41400e74-4445-49ef-90a4-98da4ccfb16c |
    | 7d275413-bc0b-4bbf-8c7b-b9522777beec | uk-slough-1-6.vchs.vmware.com     | 62155213-e5fc-448d-a46a-770c57c5dd31 |    
    

Log in again to vCloud Air, this time indicating the instance where the virtual data center is located, in my case is the instance in 'us-california-1-3...' region:

    
    vca login email@company.com --password supersecretpassword --instance c40ba6b4-c158-49fb-b164-5c66f90344fa
    

It might come in handy to create an alias for the login command, in case the authentication token expires.

    
    alias vcalogin='vca login email@company.com --password supersecretpassword --instance c40ba6b4-c158-49fb-b164-5c66f90344fa'
    

At this point you can explore the organization and virtual data center:

    
    vca org
    Available Organizations for 'default' profile:
    | Instance Id                          | Region                            | Organization Id                      | Selected   |
    |--------------------------------------+-----------------------------------+--------------------------------------+------------|
    | c40ba6b4-c158-49fb-b164-5c66f90344fa | us-california-1-3.vchs.vmware.com | a6545fcb-d68a-489f-afff-2ea055104cc1 | *          |    
    
    vca vdc
    Available Virtual Data Centers for 'default' profile:
    | Virtual Data Center   | Selected   |
    |-----------------------+------------|
    | VDC1                  |            |
    | VDC2                  |            |
    
    vca vdc use --vdc VDC1
    Using vdc 'VDC1' in profile 'default'
    Virtual Data Center 'VDC1' for 'default' profile; details:
    | Type         | Name                   |
    |--------------+------------------------|
    | edge gateway | gateway                |
    | network      | default-routed-network |
    Compute capacity:
    | Resource    |   Allocated |   Limit |   Reserved |   Used |   Overhead |
    |-------------+-------------+---------+------------+--------+------------|
    | CPU (MHz)   |           0 |  130000 |          0 |   5200 |          0 |
    | Memory (MB) |           0 |  102400 |          0 |   1024 |        123 |    
    Edge Gateways:
    | Name    | External IPs | DHCP Service   | Firewall Service   | NAT Service   | Internal Networks          |
    |---------+--------------+----------------+--------------------+---------------+----------------------------|
    | gateway | []           | Off            | On                 | Off           | ['default-routed-network'] |
    

The *status* command gives the URL of the vCloud Director instance that is required to upload the OVA template and ISO image:

    
    vca status
    
    Status:
    | Property        | Value                                                |
    |-----------------+------------------------------------------------------|
    | gateway         |                                                      |
    | host            | https://iam.vchs.vmware.com                          |
    | instance        | c40ba6b4-c158-49fb-b164-5c66f90344fa                 |
    | org             |                                                      |
    | org_url         | https://us-california-1-3.vchs.vmware.com/api/comp.. |
    | service         |                                                      |
    | service_type    | ondemand                                             |
    | service_version | 5.7                                                  |
    | session         | active                                               |
    | session_token   | 637c23fc3aa84785b072e5233ad705e4                     |
    | token           | eyJhbGciOiJSUzI1NiJ9.eyJqdGkiOiJmMmRjZmQ2Ny1jOTMxL.. |
    | user            | email@company.com                                    |
    | vdc             | VDC1                                                 |
    

First, download the OVA to the local disk. The CoreOS OVA template comes with [open-vm-tools](http://kb.vmware.com/kb/2073803) installed.

    
    wget http://alpha.release.core-os.net/amd64-usr/current/coreos_production_vmware_ova.ova
    

Then, upload it to vCloud Air using ovftool, using the URL from the *status* command and the org id from the *vca org* command:

    
    ovftool coreos_production_vmware_ova.ova \
        "vcloud://email@company.com:supersecretpassword@us-california-1-3.vchs.vmware.com:?org=a6545fcb-d68a-489f-afff-2ea055104cc1&vdc=VDC1&catalog=default-catalog&vappTemplate=coreos_template"
    

Next step is to create the VM and connect it to the network. We are not starting the VM just yet, but we'll take note of the IP assigned to the VM.

    
    vca vapp create --vapp coreos1 --template coreos_template --catalog default-catalog --network default-routed-network --mode POOL
    
    vca vm
    Available VMs in 'VDC1' for 'default' profile:
    | VM                           | vApp    | Status      | IPs               | Networks                   |   vCPUs |   Memory (GB) | CD/DVD | OS                         | Owner             |
    |------------------------------+---------+----------- -+-------------------+----------------------------+---------+---------------+--------+----------------------------+-------------------|
    | coreos_production_vmware_ova | coreos1 | Powered off | ['192.168.109.2'] | ['default-routed-network'] |       2 |             1 | []     | Other 2.6.x Linux (64-bit) | email@company.com |
    

The IP address is used in the [createiso.sh](../public/createiso.sh) script to generate the *cloud-config* ISO that the CoreOS will use to configure itself. Thanks to William Lam for providing the [original script](http://www.virtuallyghetto.com/2014/11/how-to-quickly-deploy-new-coreos-image-wvmware-tools-on-esxi.html). I have modified it to have CoreOS configure the static IP assigned by vCloud Air. It can be customized to configure additional [services and settings](https://coreos.com/docs/cluster-management/setup/cloudinit-cloud-config/).

Modify the file based on your preferences. At the very least, make sure to specify the IP address and the public ssh key:

    
    # IP Address of CoreOS Instance
    CORE_OS_IP_ADDRESS=192.168.109.2
    
    CORE_OS_AUTHORIZED_KEYS='AAAAB3NzaC1yc2EAAAADAQAB....'
    

Then create the ISO file and upload it to vCloud Air:

    
    ./createiso.sh
    
    ovftool --sourceType='ISO' coreos1-config.iso \
        "vcloud://email@company.com:supersecretpassword@us-california-1-3.vchs.vmware.com:?org=a6545fcb-d68a-489f-afff-2ea055104cc1&vdc=VDC1&catalog=default-catalog&media=coreos1-config.iso"
        

Attach the ISO to the VM and boot it up:

    
    vca vapp insert --vapp coreos1 --vm coreos_production_vmware_ova --catalog default-catalog --media coreos1-config.iso
    vca vapp power.on --vapp coreos1
    

It is required to reboot the VM to activate the changes:

    
    sleep 25
    vca vapp power.off --vapp coreos1
    vca vapp power.on --vapp coreos1
    

The final step is to configure the gateway to be able to ssh into the VM. If you haven't added a public IP address to the virtual data center, you can do it now. The *vca gateway* command will show the allocated IP.

    
    vca gateway
    Edge Gateways:
    | Name    | External IPs       | DHCP Service   | Firewall Service   | NAT Service   | Internal Networks          |
    |---------+--------------------+----------------+--------------------+---------------+----------------------------|
    | gateway | ['107.189.93.162'] | Off            | On                 | On            | ['default-routed-network'] |
    

Then, disable the firewall and create the corresponding NAT rules. On another post, I will explain how to configure firewall rules with vca-cli.

    
    vca firewall disable
    vca nat add --rule_type DNAT --original_ip 107.189.93.162 --original_port 22 --translated_ip 192.168.109.2 --translated_port 22 --protocol tcp
    vca nat add --rule_type SNAT --original_ip 192.168.109.0/24 --translated_ip 107.189.93.162
    
    vca nat
    |   Rule ID | Enabled   | Type   | Original IP      | Original Port   | Translated IP   | Translated Port   | Protocol   | Applied On   |
    |-----------+-----------+--------+------------------+-----------------+-----------------+-------------------+------------+--------------|
    |     65538 | True      | SNAT   | 192.168.109.0/24 | any             | 107.189.93.162  | any               | any        | d2p3v29-ext  |
    |     65539 | True      | DNAT   | 107.189.93.162   | 22              | 192.168.109.2   | 22                | tcp        | d2p3v29-ext  |
    

The VM is now ready to accept ssh connections. Log in to the machine with the private key:

    
    ssh -i id_rsa_coreos vcauser@107.189.93.162
    

### Summary

vCloud Air provides a feature-rich cloud service with advanced virtual data center options. This guide will help CoreOS users to quickly deploy servers on vCloud Air and customize the instances using the native *cloud-config* mechanism.
