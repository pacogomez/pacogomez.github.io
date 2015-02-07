---
layout: post
title: Quick and Easy Provisioning at vCloud Air
comments: true
permalink: /quick-and-easy-provisioning-at-vcloud-air
---

For those minimalist DevOps engineers out there, this post describes how to provision a virtual machine at vCloud Air, the quickest way possible. The steps include adding a public SSH key and configuring the network to make the machine *SSH-Ready*.

On my previous [post](http://blog.pacogomez.com/coreos-vcloud-air-on-demand/), I described how to provision CoreOS on vCloud Air. CoreOS instances get customized through [cloud-config](https://coreos.com/docs/cluster-management/setup/cloudinit-cloud-config/). A user can define the IP of the machine and add the public SSH key by including all that information in a text file included in a virtual ISO mounted on the VM.

In this post I will provision an Ubuntu VM and customize it with the VMware Guest OS Customization method. The process is done in 3 simple steps:

1. Create a VM from an Ubuntu template available in the catalog. Take note of the IP assigned.
2. Upload the public SSH key as part of the customization script to add it to the *ubuntu* user. Start the machine and perform the customization.
3. Create the NAT rule to allow SSH traffic to the machine. 

Now the machine will be ready, simply SSH into and start using it. 

I will make some assumptions, like having a vCloud Air On Demand account (Subscription or vCA-N also applies), a virtual data center has already been created, [vca-cli](https://github.com/vmware/vca-cli) is already installed on your local computer and at least one public IP address has been allocated.

Let's get started, let's login and inspect the virtual data center and catalog:

    
    $ vca login email@company.com --password supersecretpassword
    
    Login successful for profile 'default'
    
    
    $ vca vdc use --vdc VDC1
    
    Using vdc 'VDC1' in profile 'default'
    Virtual Data Center 'VDC1' for 'default' profile; details:
    | Type         | Name                   |
    |--------------+------------------------|
    | edge gateway | gateway                |
    | media        | coreos1-config.iso     |
    | network      | default-routed-network |
    | vApp         | coreos1                |
    | vApp         | coreos2                |
    | vAppTemplate | coreos_template        |
    Compute capacity:
    | Resource    |   Allocated |   Limit |   Reserved |   Used |   Overhead |
    |-------------+-------------+---------+------------+--------+------------|
    | CPU (MHz)   |           0 |  130000 |          0 |  10400 |          0 |
    | Memory (MB) |           0 |  102400 |          0 |   2048 |        151 |
    Edge Gateways:
    | Name    | External IPs       | DHCP Service   | Firewall Service   | NAT Service   | Internal Networks          |
    |---------+--------------------+----------------+--------------------+---------------+----------------------------|
    | gateway | ['107.189.93.162'] | Off            | Off                | On            | ['default-routed-network'] |
    
    
    $ vca catalog
    
    Catalogs and items:
    | Catalog         | Item                               |
    |-----------------+------------------------------------|
    | Public Catalog  | CentOS64-64Bit                     |
    | Public Catalog  | CentOS63-32bit                     |
    | Public Catalog  | UbuntuServer1204LTS-amd64-20140927 |
    | Public Catalog  | W2K12-STD-R2-64BIT                 |
    | Public Catalog  | Ubuntu-Server1204LTS-i386-20140927 |
    | Public Catalog  | W2K12-STD-64BIT                    |
    | Public Catalog  | CentOS63-64Bit                     |
    | Public Catalog  | CentOS64-32bit                     |
    | Public Catalog  | W2K8-STD-R2-64BIT                  |
    | default-catalog | coreos_template                    |
    | default-catalog | coreos1-config.iso                 |
    

Now let's create the VM and see what IP address has been assigned by vCA:

    
    $ vca vapp create -a ubu -V ubu -c 'Public Catalog' -t UbuntuServer1204LTS-amd64-20140927 -n default-routed-network -m POOL
    
    creating vApp 'ubu' in VDC 'VDC1' from template 'UbuntuServer1204LTS-amd64-20140927' in catalog 'Public Catalog'
    disconnecting vApp from networks pre-defined in the template
    connecting vApp to network 'default-routed-network' with mode 'POOL'
    connecting VMs to network 'default-routed-network' with mode 'POOL'
    
    
    $ vca vapp
    
    Available vApps in 'VDC1' for 'default' profile:
    | vApp    | VMs         | Status      | Deployed   |   Description |
    |---------+-------------+-------------+------------+---------------|
    | coreos1 | ['coreos1'] | Powered on  | yes        |               |
    | coreos2 | ['coreos2'] | Powered off | yes        |               |
    | ubu     | ['ubu']     | Powered off | yes        |               |
    
    
    $ vca vm
    
    Available VMs in 'VDC1' for 'default' profile:
    | VM      | vApp    | Status      | IPs               | Networks                   |   vCPUs |   Memory (GB) | CD/DVD                 | OS                         | Owner             |
    |---------+---------+-------------+-------------------+----------------------------+---------+---------------+------------------------+----------------------------+-------------------|
    | coreos2 | coreos2 | Powered off | ['192.168.109.3'] | ['default-routed-network'] |       2 |             1 | []                     | Other 2.6.x Linux (64-bit) | email@company.com |
    | coreos1 | coreos1 | Powered on  | ['192.168.109.2'] | ['default-routed-network'] |       2 |             1 | ['coreos1-config.iso'] | Other 2.6.x Linux (64-bit) | email@company.com |
    | ubu     | ubu     | Powered off | ['192.168.109.4'] | ['default-routed-network'] |       1 |             1 | []                     | Ubuntu Linux (64-bit)      | email@company.com |
    

The IP assigned is '192.168.109.4'.

It is possible to script the retrieval of the IP. vca-cli has the option to print out tables in JSON format (-j or --json). We can use [jq](http://stedolan.github.io/jq/) to get the IP and save it in a variable to use it in the future:

    
    $ IP=`vca -j vm -a ubu | jq '.vms[0].IPs[0]'` && echo $IP
    

A customization script is a normal shell script that is added to the VM properties and then executed by the [VMware tools](http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=340) running on the Guest OS when the operation *start VM and force customization* is performed. I have created a simple [customization script](../public/add_public_ssh_key.sh) that adds the SSH public key to the *authorized_keys* file of the *ubuntu* user account. We can use vca-cli to upload the script and perform the customization:

    
    $ vca vapp undeploy --vapp ubu
    
    undeploying vApp 'ubu' from VDC 'VDC1'
    
    
    $ vca vapp customize --vapp ubu --vm ubu --file add_public_ssh_key.sh
    
    customizing VM 'ubu' in vApp 'ubu' in VDC 'VDC1'
    uploading customization script
    deploying and starting the vApp
    


As a final step, let's configure the NAT rule to allow to SSH into the machine:

    
    $ vca nat add --rule_type DNAT --original_ip 107.189.93.162 --original_port 422 --translated_ip 192.168.109.4 --translated_port 22 --protocol tcp
    

It not done it before, configure a general SNAT rule and disable the firewall:

    
    $ vca nat add --rule_type SNAT --original_ip 192.168.109.0/24 --translated_ip 107.189.93.162
    
    $ vca firewall disable
    
    $ vca nat
    
    |   Rule ID | Enabled   | Type   | Original IP      | Original Port   | Translated IP   | Translated Port   | Protocol   | Applied On   |
    |-----------+-----------+--------+------------------+-----------------+-----------------+-------------------+------------+--------------|
    |     65538 | True      | SNAT   | 192.168.109.0/24 | any             | 107.189.93.162  | any               | any        | d2p3v29-ext  |
    |     65539 | True      | DNAT   | 107.189.93.162   | 22              | 192.168.109.2   | 22                | tcp        | d2p3v29-ext  |
    |     65540 | True      | DNAT   | 107.189.93.162   | 422             | 192.168.109.4   | 22                | tcp        | d2p3v29-ext  |
    

And that's all, now SSH into the new VM using the private SSH key:

    
    $ ssh -i ~/.ssh/id_rsa_vca ubuntu@107.189.93.162 -p 422
    ...
    Welcome to Ubuntu 12.04.5 LTS (GNU/Linux 3.13.0-36-generic x86_64)
    ...
    ubuntu@UbuntuServe-001:~$
        

Cool! 

You might want to configure a couple of things. Set the DNS settings:

    
    sudo -i 
    echo 'dns-nameservers 8.8.8.8' >> /etc/network/interfaces
    ifdown eth0 && ifup eth0
    

And upgrade to the latest release (14.04):

    
    sudo -i
    apt-get update
    do-release-upgrade -f DistUpgradeViewNonInteractive
    reboot
    

After the upgrade is finished, you can save the virtual machine as a template in the catalog. The next VMs can be created from the new template instead of the public catalog template and save extra pre-configuration efforts. But that will be the topic of a future blog entry.

### Summary

vCloud Air On Demand users can provision *SSH-ready* machines in just a few simple vca-cli commands. The process described here can also be used to initialize the VMs with other customization scripts and bootstrap an entire custom environment in a few minutes.
