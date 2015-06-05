---
layout: post
title: TOSCA Blueprints at vCloud Air
comments: true
permalink: /tosca-blueprints-at-vcloud-air
---

The [vCloud Air Command Line Interface](/overview-of-vca-cli-features) is a traditional solution for interactive, text-based operations, which allows scripting and *lightweight* automation. In this post I'm going to talk about another approach to automation that we've been working on at vCloud Air for the last few months: TOSCA Application Blueprints.

[TOSCA](https://www.oasis-open.org/committees/tosca) (Topology and Orchestration Specification for Cloud Applications) is an open standard from [OASIS](https://www.oasis-open.org) that aims to enhance portability and management of cloud applications and services. In practical terms, a TOSCA service template (or application blueprint) is a document written in YAML that adheres to the syntax defined by the specification. The template is submitted to a TOSCA-compliant orchestration engine and, as a result, the application gets deployed and configured on the cloud provider of choice.

The [draft 03](http://docs.oasis-open.org/tosca/TOSCA-Simple-Profile-YAML/v1.0/csd03/TOSCA-Simple-Profile-YAML-v1.0-csd03.html) of the spec has been recently published and is worth taking a look as it has many good examples. But nothing beats a working demo and here I will describe the steps to deploy a TOSCA blueprint on vCloud Air. The implementation is based on [Cloudify](http://getcloudify.org), an Open Source TOSCA-based orchestration engine from [GigaSpaces](http://www.gigaspaces.com), and the [TOSCA vCloud plugin](https://github.com/vmware/tosca-vcloud-plugin) developed as a joint collaboration between VMware vCloud Air and GigaSpaces.

### Requisites

To run this demo yourself, you need a vCloud Air account (Sign Up for a $300 in service credit [here](http://vcloud.vmware.com/service-offering/virtual-private-cloud-ondemand)) and a machine with Python, PyPi, Virtualenv and git.

### Installation

Start by opening a console and creating a working directory, create a Python virtual environment and install `cloudify` and `vca-cli`:

    $ mkdir ~/tosca
    
    $ cd ~/tosca
    
    $ virtualenv .venv
    
    $ source .venv/bin/activate
    
    $ pip install cloudify
    
    $ pip install vca-cli
    

### The Blueprint

The sample TOSCA blueprint is located at [this](https://github.com/vmware/tosca-blueprints) public repository. The blueprint contains a virtual machine that is connected to a network and has a public IP address. The blueprint also defines that a web server (`ngnix`) should be installed on the virtual machine and that ports 22 and 80 should be accessible from outside.

This simple blueprint illustrates two important concepts in TOSCA orchestration:

- **infrastructure provisioning**: a vApp/VM is instantiated on a virtual datacenter from a template and network resources are configured according to the template

- **software configuration**: in this case, a web server gets installed and started on the VM created previously

Ok, let's get the blueprint and customize the input values:

    $ git clone https://github.com/vmware/tosca-blueprints.git
    
    $ cd tosca-blueprints/helloworld
    
    $ cp input-template-ondemand.yaml my-input-values.yaml
    

Edit the file `my-input-values.yaml` and modify the following properties:

| Property        | Value           | Notes |
| ------------- |-------------| -----|
| vcloud_username | your vCloud Air username | provide your own |
| vcloud_password | the password | use single quotes |
| vcloud_instance | your vCloud Air instance | use `vca instance` |
| vcloud_vdc | the virtual datacenter | use `vca vdc`|
| public_ip | the public IP | use `vca gateway` |
| ssh_public_key | SSH public key | use `ssh-keygen`|
| ssh_private_key_path | local path of the private SSH key | e.g. `~/.ssh/id_rsa` |

### Orchestrating the Blueprint

When creating blueprints, it is important to make sure the document is correct. Use the `validate` command in `cfy`:

    $ cfy blueprints validate --blueprint blueprint.yaml
    

To orchestrate the blueprint, we are going to use `cfy`, the [Cloudify Command Line Interface](http://getcloudify.org/guide/3.2/cli-general.html). Other methods to deploy the blueprint are available, including the Cloudify [manager](http://getcloudify.org/guide/3.2/overview-components.html). The first step is to initialize a local workflow execution environment in the current directory. The command also installs the plugins indicated in the blueprint:

    $ cfy local init -p blueprint.yaml -i my-input-values.yaml \
          --install-plugins
    

We are now ready to deploy our application, by running the `install` workflow of the blueprint:

    $ cfy local execute -w install --task-retries 10 \
                                   --task-retry-interval 10
    

After a few minutes, we should get a message indicating that the workflow ended successfully:

    2015-06-05 08:40:10 CFY <local> 'install' workflow execution succeeded
    

To check that the application is up and running, open a browser to the public IP specified in the blueprint:

    $ open http://107.189.85.67
    

You should get the familiar welcome page of `ngnix`. You can also use `vca-cli` to check the created VM and the NAT rules configured by the blueprint:

    $ vca vm
    
    Available VMs in 'VDC1' for 'default' profile:
    | VM     | vApp   | Status     | IPs           | Networks               |   vCPUs |   Memory (GB) | 
    |--------+--------+------------+---------------+------------------------+---------+---------------+-
    | hellow | hellow | Powered on | 192.168.109.2 | default-routed-network |       3 |             2 | 
    
    
    $ vca nat
    
    NAT rules
    |   Rule Id | Enabled   | Type   | Original IP   | Original Port   | Translated IP   | Translated Port   | Protocol   | Applied On   |
    |-----------+-----------+--------+---------------+-----------------+-----------------+-------------------+------------+--------------|
    |     65537 | True      | SNAT   | 192.168.109.2 | any             | 107.189.85.67   | any               | any        | d3p4v54-ext  |
    |     65538 | True      | DNAT   | 107.189.85.67 | 22              | 192.168.109.2   | 22                | tcp        | d3p4v54-ext  |
    |     65539 | True      | DNAT   | 107.189.85.67 | 80              | 192.168.109.2   | 80                | tcp        | d3p4v54-ext  |
    


### Cleaning Up

When the time comes to tear down the application, just execute the `uninstall` workflow of the blueprint:

    $ cfy local execute -w uninstall
    
    [messages ommitted]
    
    CFY <local> 'uninstall' workflow execution succeeded
    

After the workflow ends, the provisioned VM will be deleted and the NAT rules created by the `install` workflow will be also deleted, leaving your virtual datacenter in the same state as it was before.

### Summary

Application orchestration represents a higher level of abstraction that is designed for automating deployments on the cloud. vCloud Air customers can now write application blueprints in TOSCA and deploy service templates using Cloudify and the plugin for vCloud.


