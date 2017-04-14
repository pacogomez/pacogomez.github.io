---
layout: post
title: vca-cli and vCloud Director 8.20
comments: true
permalink: /vca-cli-vcloud-director-8-20
---

It's been a while since my last post and a few things happened since then. Among others, the release of [vCloud Director 8.20 for Service Providers](http://www.vmware.com/products/vcloud-director.html). The latest version of vCloud Director is fully supported by [vca-cli](https://github.com/vmware/vca-cli) (vCloud Air Command Line Interface). This post provides several examples of using `vca-cli` with `vCD 8.20` for performing common tasks.

### Requisites

To run the examples in this post, you need an account on a vCloud Director 8.20 instance and a machine with `Python` and `PyPi` (macOS, Linux or Windows).

### Installation

Start by opening a console and install `vca-cli`:

    $ pip install --user vca-cli

That should install the latest version of `vca-cli` (18 at the time of writing). In this version we added the `vcd` command alias, so `vca-cli` can be invoked with using the `vca` or `vcd` commands available after the installation.

    $ vcd --version

    vca-cli version 18 (pyvcloud: 16)

If a previous version of `vca-cli` is already installed, upgrade to the latest with:

    $ pip install --user vca-cli --upgrade

### Login

The following command logs the user to a vCloud Director 8.20 instance. The required parameters for the `login` command are `username`, `password`, `host` and `org` (organization). Since this is a development `vCD` instance with self-signed certificates, we need to add the `-i` (insecure) flag to the login and to every command connecting to that `vCD` host.

    $ vcd -i login usr1 \
          --password mysecretpass \
          --host vcd.cpsbu.eng.vmware.com \
          --org org1

    InsecureRequestWarning: Unverified HTTPS request is being made. Adding certificate verification is strongly advised.
    User 'usr1' logged in, profile 'oc1'
    Password encrypted and saved in local profile. Use --do-not-save-password to disable it.
    Using VDC 'o1vdc1', profile 'oc1'

### Looking Around

Once we logged in, we can retrieve the details of the current organization:

    $ vcd -i org info

    InsecureRequestWarning: Unverified HTTPS request is being made. Adding certificate verification is strongly advised.
    Details for instance:org 'None':'org1', profile 'oc1':
    | Type       | Name                                 |
    |------------+--------------------------------------|
    | Org Id     | fddeb52e-cdca-4f77-8b7f-ef5f899d604c |
    | Org Name   | org1                                 |
    | catalog    | mycatalog                            |
    | orgNetwork | onet100                              |
    | vdc        | o1vdc1                               |

Note: If the `-i` flag is missing when connecting to a self-signed certificates instance, `vca-cli` will reply with `Not logged in` message.

We can take a look at the current organization virtual datacenter:

    $ vcd -i vdc info

    InsecureRequestWarning: Unverified HTTPS request is being made. Adding certificate verification is strongly advised.
    Details of Virtual Data Center 'o1vdc1', profile 'oc1':
    | Type              | Name            |
    |-------------------+-----------------|
    | gateway           | gw1             |
    | network           | onet100         |
    | vApp              | cnt             |
    | vAppTemplate      | centos-7-x86_64 |
    | vdcStorageProfile | *               |
    Compute capacity:
    | Resource    |   Allocated |   Limit |   Reserved |   Used |   Overhead |
    |-------------+-------------+---------+------------+--------+------------|
    | CPU (MHz)   |           0 |       0 |          0 |   2000 |          0 |
    | Memory (MB) |           0 |       0 |          0 |   2048 |         34 |

list the templates in the catalog:

    $ vcd -i catalog

    InsecureRequestWarning: Unverified HTTPS request is being made. Adding certificate verification is strongly advised.
    Available catalogs and items in org 'org1', profile 'oc1':
    | Catalog   | Item            |
    |-----------+-----------------|
    | mycatalog | centos-7-x86_64 |

the virtual machines running:

    $ vcd -i vm

    InsecureRequestWarning: Unverified HTTPS request is being made. Adding certificate verification is strongly advised.
    Available VMs in 'o1vdc1', profile 'oc1':
    | VM   | vApp   | Status     | IPs           | Networks   |   vCPUs |   Memory (GB) | CD/DVD   | OS                      | Owner   |
    |------+--------+------------+---------------+------------+---------+---------------+----------+-------------------------+---------|
    | cnt  | cnt    | Powered on | 192.168.100.1 | onet100    |       2 |             2 |          | CentOS 4/5/6/7 (64-bit) | usr1    |

and the networks configured in the datacenter:

    $ vcd -i network

    InsecureRequestWarning: Unverified HTTPS request is being made. Adding certificate verification is strongly advised.
    Available networks in 'o1vdc1', profile 'oc1':
    | Name    | Mode      | Gateway         | Netmask       | DNS 1           | DNS 2   | Pool IP Range                |
    |---------+-----------+-----------------+---------------+-----------------+---------+------------------------------|
    | onet100 | natRouted | 192.168.100.254 | 255.255.255.0 | 192.168.100.254 |         | 192.168.100.1-192.168.100.20 |

### Using Virtual Machines

To `power off` a running virtual machine, use the `vapp` command:

    $ vcd -i vapp power-off --vapp cnt

    InsecureRequestWarning: Unverified HTTPS request is being made. Adding certificate verification is strongly advised.
    | Start Time          | Duration      | Status   |
    |---------------------+---------------+----------|
    | 2017-04-14 10:26:04 | 0 mins 9 secs | success  |

Let's check the current status:

    $ vcd -i vm

    InsecureRequestWarning: Unverified HTTPS request is being made. Adding certificate verification is strongly advised.
    Available VMs in 'o1vdc1', profile 'oc1':
    | VM   | vApp   | Status      | IPs           | Networks   |   vCPUs |   Memory (GB) | CD/DVD   | OS                      | Owner   |
    |------+--------+-------------+---------------+------------+---------+---------------+----------+-------------------------+---------|
    | cnt  | cnt    | Powered off | 192.168.100.1 | onet100    |       2 |             2 |          | CentOS 4/5/6/7 (64-bit) | usr1    |

It is powered off, we can now power the VM on:

    $ vcd -i vapp power-on --vapp cnt

    InsecureRequestWarning: Unverified HTTPS request is being made. Adding certificate verification is strongly advised.
    | Start Time          | Duration      | Status   |
    |---------------------+---------------+----------|
    | 2017-04-14 10:27:38 | 0 mins 4 secs | success  |

And check its status:

    $ vcd -i vm

    InsecureRequestWarning: Unverified HTTPS request is being made. Adding certificate verification is strongly advised.
    Available VMs in 'o1vdc1', profile 'oc1':
    | VM   | vApp   | Status     | IPs           | Networks   |   vCPUs |   Memory (GB) | CD/DVD   | OS                      | Owner   |
    |------+--------+------------+---------------+------------+---------+---------------+----------+-------------------------+---------|
    | cnt  | cnt    | Powered on | 192.168.100.1 | onet100    |       2 |             2 |          | CentOS 4/5/6/7 (64-bit) | usr1    |

### Summary

`vca-cli` supports the latest vCloud Director version 8.20. In this post I provided some usage examples. In future posts I will cover other aspects of `vca-cli` with vCloud Director, including some upcoming features. More information about `vca-cli` can be found in the [project wiki](https://github.com/vmware/vca-cli/wiki) and in some of my previous posts.
