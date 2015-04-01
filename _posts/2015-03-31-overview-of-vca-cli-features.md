---
layout: post
title: Overview of vca-cli Features
comments: true
permalink: /overview-of-vca-cli-features
---

In previous posts I have introduced [vca-cli](https://github.com/vmware/vca-cli) (vCloud Air Command Line Interface) and provided examples of specific use cases. This post gives an overview of the current features (as of version 10) and highlights some vCloud Air features that are only available through vca-cli (or through API): independent disks management, [edge gateway logs capture](/monitoring-the-firewall-at-vcloud-air/) and advanced VPN tunnel configuration.

If you would like to explore the features described in this post, you can [install](https://github.com/vmware/vca-cli#installation) vca-cli with pip: `pip install vca-cli`, or upgrade an existing installation: `pip install --upgrade vca-cli`. vca-cli can also produce a list of examples (77) with the `vca example` command, that comes in handy to see what's available and how to use it. vca-cli is multiplatform and works on Windows, Linux and Mac.

The structure of vca-cli commands is:

    $ vca [OPTIONS] COMMAND [SUB-COMMAND] [OPTIONS]...

As a general rule, `COMMAND` identifies an entity in vCloud Air, to which the action will be applied. And `SUB-COMMAND` identifies the action to be applied, which might contain zero or more options. By default, if a vca-cli command is called without a sub-command, the sub-command to be applied is `list`. For example, `vca vdc` is equivalent to `vca vdc list` and `vca vm` is equivalent to `vca vm list`. Sub-commands commonly available across vca-cli commands are `list`, `info`, `use`, `add`, `create` and `delete`. The available commands can be listed with `vca --help` and help on a specific command with `vca <command> --help`. More information can be found in the [vca-cli](https://github.com/vmware/vca-cli#usage) public repository.

## Signing in and getting around

vca-cli can be used with vCloud Air (OnDemand and Subscription) and vCloud Director standalone. It also works with installations of vCloud Director that have self-signed SSL certificates. The command for login to the service is `vca login` and accepts the password as an argument or as value to be entered by the user with no echo after a prompt. It also supports auto-relogin when the session expires, by saving the password encrypted in the user's profile (~/.vcarc).

Here is a sample login command for vCA OnDemand:

    $ vca login user@company.com --password mysecretpass --save-password \
                --instance c40ba6b4-c158-49fb-b164-5c66f90344fa

In case of vCA OnDemand, the user signs into a particular instance (in a region) and is associated with a specific organization. Details of the organization can be retreived with `vca org info`. Within that organization, the user can access one or more virtual data centers (VDC). `vca vdc` lists available virtual data centers. `vca vdc use --vdc VDC1` selects a specific data center and the selection is active (stored in the profile) until the user signs off or selects a different virtual data center. `vca vdc info` provides summary information about the currently selected data center.

## Compute and Storage

vca-cli allows the creation of new virtual machines (vApp) from a template. The `vca catalog` command lists available catalogs and templates. Catalogs can be created and deleted with the corresponding sub-commands. The `vca vapp` command allows the creation and life cycle management of virtual machines (defined inside a vApp). `vca vm` provides details of virtual machines contained in a vApp. The following commands show how to create, customize and power on, list, power off and delete a vApp:

    $ vca vapp create --vapp myvapp --vm myvm \
               --catalog 'Public Catalog' --template 'Ubuntu Server 12.04 LTS (amd64 20150127)' \
               --network default-routed-network --mode POOL 
    
    $ vca vapp customize --vapp myvapp --vm myvm \
               --file add_public_ssh_key.sh
    
    $ vca vapp
    
    $ vca vm
    
    $ vca vapp power.off --vapp myvapp
    
    $ vca vapp delete --vapp myvapp

vCloud Air supports independent disks. These virtual disks can be created as standalone entities and attached to virtual machines as needed. The management of independent disks is conveniently supported by vca-cli, as the vCloud Director web interface just lists disks that have been previously created. For example: 

    $ vca disk create -d d1 -s 100
    
    $ vca vapp attach -d d1 -a myvapp -v myvm 

Creates an independent disk (d1) of 100GB and attaches it to a virtual machine. Disks can also be detached, listed and deleted.

Another useful feature is the ability to insert (`vca vapp insert` command) an ISO file into a virtual machine. This allows to script the customization of guest operating systems that rely on cloud-init, as described [here](/coreos-vcloud-air-on-demand/). ISO files can also be ejected with the `vca vapp eject` command.

## Networking

The rich networking functionality in vCloud Air is also available to users through vca-cli. vca-cli supports management of networks and edge gateway services. Detailed networking capabilities are described [here](https://github.com/vmware/vca-cli/wiki/Networking).

The `vca network` command lists, creates and deletes networks. The following example creates a routed network and defines the pool of IP addresses to be used to assign to virtual machines in 'static-pool' mode, then lists and delete the network:

    $ vca network create --network mynetwork --gateway mygateway \
                         --netmask 255.255.255.0 \
                         --gateway-ip 192.168.117.1 --dns1 192.168.117.1 \
                         --pool 192.168.117.2-192.168.117.100
    $ vca network
    
    $ vca network delete --network mynetwork

vCloud Air edge gateway provides a set of network services to a virtual data center. `vca gateway` shows a summary information of the gateway serving the current data center. The `info` sub-command provides more details about the gateway, as shown here:

    $ vca gateway info --gateway mygateway

The individual edge gateway services can be configured with the corresponding commands, as listed in the following table:

Service   | Command
--------- | -------
DHCP      | `vca dhcp`
Network Address Translation (NAT)       | `vca nat`
Firewall  | `vca firewall`
IPsec VPN | `vca vpn`

The following example shows how to enable DHCP service and how to configure a range of IP addresses to be offered in a particular network:

    $ vca dhcp enable
    
    $ vca dhcp add --network mynetwork --pool 192.168.117.101-192.168.117.200

The edge gateway NAT service allows the mapping of external IP addresses and ports to internal ones. `vca nat` shows the current configuration of the NAT service, listing the NAT rules defined. The following commands provide examples to create and delete NAT rules:

    $ vca nat add --type DNAT \
          --original-ip 107.189.77.232 --original-port 22 \
          --translated-ip 192.168.117.5 --translated-port 22 \
          --protocol tcp
    
    $ vca nat add --type SNAT \
          --original-ip 192.168.117.0/24 --translated-ip 107.189.77.232

For convenience, it is possible to pass a file that contains several NAT rules and vca-cli will configure them all in one call.

The current version of vca-cli can enable (`vca firewall enable`) and disable (`vca firewall disable`) the firewall service . Adding firewall rules will be supported in future versions.

IPsec VPN is another service provided by the edge gateway and available through vca-cli. Creating a VPN tunnel involves enabling VPN, configuring the local endpoint and adding a VPN tunnel. A similar process is executed on the peer side. Here is an example:

    $ vca vpn enable
    
    $ vca vpn add-endpoint --network d3p5-ext --public-ip 23.92.225.125
    
    $ vca vpn add-tunnel --tunnel vpn1 \
          --local-ip 107.189.77.232 --local-network routed-117 \
          --peer-ip 23.92.225.125 --peer-network 192.168.115.0/24 \
          --secret 123456789012345678901234567890Az

A convenient feature of vca-cli is the ability to add (or delete) a network to an existing tunnel, without having to delete and re-create the entire tunnel. Here is an example:

    $ vca vpn add-network --tunnel vpn1 --local-network routed-116

The edge gateway can be configured to send log events to a server for analysis, with a simple option of the `gateway` command. Here is an example:

    $ vca gateway set-syslog --gateway gateway --ip 192.168.117.25

The following blog entry contains additional information about capturing [edge gateway logs](http://blog.pacogomez.com/monitoring-the-firewall-at-vcloud-air/)

## Summary

vca-cli lets you interact with vCloud Air directly from your terminal. vca-cli coverage of vCloud Air functionality is rapidly growing, allowing you to do many of the operations that you do through the web portal (and more), with the convenience of a easy-to-use set of commands.

