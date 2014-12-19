---
layout: post
title: vCloud Air Command Line Interface
comments: true
permalink: /vcloud-air-command-line-interface
---

As a cloud provider, <a href="http://vcloud.vmware.com">VMware vCloud Air</a> has a rich set of functionality available to users through the [Portal](http://pubs.vmware.com/vca/index.jsp#com.vmware.vca.ug.doc/GUID-5001DAA0-E7F7-41FE-B137-AE673A5DD192.html) and the [API](http://pubs.vmware.com/vca/index.jsp#com.vmware.vca.api.doc/GUID-0BE81A1E-1EDA-4020-9969-A355EC6D9640.html"). With the release of the [vCloud Air Command Line Interface](https://github.com/vmware/vca-cli) (vca-cli), users have now another method to access the service and leverage the benefits of scripting for automation and documentation purposes.

The **vca-cli** is a cross-platform tool that exposes the rich vCloud Air API with a command line interface. The following entry is an introduction on how to install and use **vca-cli**.

**vca-cli** requires [Python](https://www.python.org/) and [pip](https://pip.pypa.io/en/latest/installing.html). Make sure these two components are properly installed on your system. After that, simply install **vca-cli** with:

    
    $ pip install vca-cli
    

You will also need a vCloud Air account, of course. Log in to vCloud Air with your credentials:

    
    $ vca login myname@mycomp.com
    Password: ********
    Login successful with profile 'default'
    

Alternatively:

    
    $ vca login myname@mycomp.com --password my_secret_password
    Login successful with profile 'default'
    

Upon successful login, list the **services** and **virtual datacenters** that you have access to:

    
    $ vca services    
    Available services for 'default' profile:
    | ID              | Type                   | Region          |
    |-----------------+------------------------+-----------------|
    | 85-719          | compute:dedicatedcloud | US - Nevada     |
    | 20-162          | compute:vpc            | US - Nevada     |
    | M536557417-4609 | compute:dr2c           | US - California |
    | M869414061-4607 | compute:dr2c           | US - Nevada     |
    | M409710659-4610 | compute:dr2c           | US - Texas      |
    | M371661272-4608 | compute:dr2c           | US - Virginia   |    
    
    
    $ vca datacenters --service 85-719
    Available datacenters in service '85-719' for 'default' profile:
    | Virtual Data Center   | Status   | Service ID   | Service Type           | Region      |
    |-----------------------+----------+--------------+------------------------+-------------|
    | Marketing             | Active   | 85-719       | compute:dedicatedcloud | US - Nevada |
    | RnD                   | Active   | 85-719       | compute:dedicatedcloud | US - Nevada |
    | Production            | Active   | 85-719       | compute:dedicatedcloud | US - Nevada |
    | DevOps                | Active   | 85-719       | compute:dedicatedcloud | US - Nevada |
    | AppServices           | Active   | 85-719       | compute:dedicatedcloud | US - Nevada |    
    
    

Once you have identified your **datacenter**, list the **gateway**. Usually the **gateway** has the same name as the **datacenter**.

    
    $ vca gateways --service 85-719 --datacenter AppServices
    Available gateways in datacenter 'AppServices' in service '85-719' for 'default' profile:
    | Datacenter   | Gateway     |
    |--------------+-------------|
    | AppServices  | AppServices |
    
    

For convenience you can configure the default values for **service**, **datacenter** and **gateway**. These values are stored in the default profile:

    
    $ vca profiles --service 85-719 --datacenter AppServices --gateway AppServices set
    Profile-default
    	host=https://vchs.vmware.com
    	user=myname@mycomp.com
    	service=85-719
    	gateway=AppServices
    	datacenter=AppServices
    	token=d188143a5d4642745d9c46c696...
    

At any given time, you can check the status of the **vca-cli** and the session with the service:

    
    $ vca status
    profile:    default
    host:       https://vchs.vmware.com
    user:       myname@mycomp.com
    service:    85-719
    datacenter: AppServices
    gateway:    AppServices
    session:    active    
    

**vca-cli** can list the **vApps**, **VMs** and **templates** in the **datacenter**:

    
    
    $ vca vapps --vms
    list of vApps
    | Service   | Datacenter   | vApp   | VMs     | Status     | Owner            | Date Created        |
    |-----------+--------------+--------+---------+------------+------------------+---------------------|
    | 85-719    | AppServices  | ub     | ['ub']  | Powered on | myname@mycomp.com | 12/11/2014 05:41:17 |
    | 85-719    | AppServices  | cts    | ['cts'] | Powered on | myname@mycomp.com | 12/11/2014 02:58:13 |    
    
    
    $ vca templates
    list of templates
    | Catalog        | Template                                 | Status   | Owner             |   # VMs |   # CPU |   Memory(GB) |   Storage(GB) | Storage Profile   |
    |----------------+------------------------------------------+----------+-------------------+---------+---------+--------------+---------------+-------------------|
    | blueprints     | cts_6_4_64bit                            | RESOLVED | myname@mycomp.com |       1 |       1 |            2 |            20 | SSD-Accelerated   |
    | Public Catalog | W2K8-STD-R2-64BIT-SQL2K8-STD-R2-SP2      | RESOLVED | catalog_admin     |       1 |       1 |            4 |            41 | SSD-Accelerated   |
    | Public Catalog | W2K12-STD-64BIT-SQL2K12-STD-SP1          | RESOLVED | catalog_admin     |       1 |       1 |            4 |            41 | SSD-Accelerated   |
    | Public Catalog | CentOS64-32Bit                           | RESOLVED | system            |       1 |       1 |            1 |            20 | SSD-Accelerated   |
    | Public Catalog | W2K12-STD-64BIT-SQL2K12-WEB-SP1          | RESOLVED | catalog_admin     |       1 |       1 |            4 |            41 | SSD-Accelerated   |
    | Public Catalog | W2K12-STD-R2-64BIT                       | RESOLVED | system            |       1 |       1 |            4 |            41 | SSD-Accelerated   |
    | Public Catalog | W2K12-STD-R2-SQL2K14-WEB                 | RESOLVED | system            |       1 |       1 |            4 |            41 | SSD-Accelerated   |
    | Public Catalog | CentOS64-64Bit                           | RESOLVED | system            |       1 |       1 |            1 |            20 | SSD-Accelerated   |
    | Public Catalog | W2K8-STD-R2-64BIT-SQL2K8-WEB-R2-SP2      | RESOLVED | catalog_admin     |       1 |       1 |            4 |            41 | SSD-Accelerated   |
    | Public Catalog | Ubuntu Server 12.04 LTS (i386 20140927)  | RESOLVED | system            |       1 |       1 |            1 |            10 | SSD-Accelerated   |
    | Public Catalog | Ubuntu Server 12.04 LTS (amd64 20140927) | RESOLVED | system            |       1 |       1 |            1 |            10 | SSD-Accelerated   |
    | Public Catalog | CentOS63-64Bit                           | RESOLVED | system            |       1 |       1 |            1 |            20 | SSD-Accelerated   |
    | Public Catalog | W2K8-STD-R2-64BIT                        | RESOLVED | system            |       1 |       1 |            2 |            41 | SSD-Accelerated   |
    | blueprints     | ubuntu_1204_64bit                        | RESOLVED | myname@mycomp.com |       1 |       2 |            4 |            67 | SSD-Accelerated   |
    | Public Catalog | W2K12-STD-64BIT                          | RESOLVED | catalog_admin     |       1 |       1 |            4 |            41 | SSD-Accelerated   |
    | Public Catalog | CentOS63-32Bit                           | RESOLVED | system            |       1 |       1 |            1 |            20 | SSD-Accelerated   |
    | Public Catalog | W2K12-STD-R2-SQL2K14-STD                 | RESOLVED | system            |       1 |       1 |            4 |            41 | SSD-Accelerated   |    
    
    

One of the most useful features is the ability to work with the datacenter edge gateway. The **nat** subcommand lists the NAT rules currently defined in the edge gateway:

    
    $ vca nat
    list of nat rules
    |   Rule ID | Enabled   | Type   | Original IP      | Original Port   | Translated IP   | Translated Port   | Protocol   | Applied On   |
    |-----------+-----------+--------+------------------+-----------------+-----------------+-------------------+------------+--------------|
    |     65538 | True      | SNAT   | 192.168.109.0/24 | any             | 192.240.158.81  | any               | any        | d0p1-ext     |
    |     65537 | True      | DNAT   | 192.240.158.81   | 22              | 192.168.109.2   | 22                | tcp        | d0p1-ext     |
    |     65540 | True      | DNAT   | 192.240.158.81   | 8080            | 192.168.109.4   | 8080              | tcp        | d0p1-ext     |
    

It is possible to add a NAT rule (DNAT or SNAT):

    
    $ vca nat add DNAT 192.240.158.81 80 192.168.109.2 80 tcp
    adding nat rule
    +-------------+-----------------------------------------------------------------------------------------------+
    | @startTime  | 2014-12-18T02:58:24.777Z                                                                      |
    +-------------+-----------------------------------------------------------------------------------------------+
    | @status     | running                                                                                       |
    +-------------+-----------------------------------------------------------------------------------------------+
    | @href       | https://p1v21-vcd.vchs.vmware.com/api/task/1e449f40-c25f-4037-8475-ff783dca5eef               |
    +-------------+-----------------------------------------------------------------------------------------------+
    | task:cancel | https://p1v21-vcd.vchs.vmware.com/api/task/1e449f40-c25f-4037-8475-ff783dca5eef/action/cancel |
    +-------------+-----------------------------------------------------------------------------------------------+
    |   Rule ID | Enabled   | Type   | Original IP      | Original Port   | Translated IP   | Translated Port   | Protocol   | Applied On   |
    |-----------+-----------+--------+------------------+-----------------+-----------------+-------------------+------------+--------------|
    |     65538 | True      | SNAT   | 192.168.109.0/24 | any             | 192.240.158.81  | any               | any        | d0p1-ext     |
    |     65537 | True      | DNAT   | 192.240.158.81   | 22              | 192.168.109.2   | 22                | tcp        | d0p1-ext     |
    |     65540 | True      | DNAT   | 192.240.158.81   | 8080            | 192.168.109.4   | 8080              | tcp        | d0p1-ext     |
    |     65541 | True      | DNAT   | 192.240.158.81   | 23              | 192.168.109.2   | 22                | tcp        | d0p1-ext     |
    |     65542 | True      | DNAT   | 192.240.158.81   | 80              | 192.168.109.2   | 80                | tcp        | d0p1-ext     |
    

... and to delete NAT rules:

    $ vca nat del DNAT 192.240.158.81 80 192.168.109.2 80 tcp
    deleting nat rule
    +-------------+-----------------------------------------------------------------------------------------------+
    | @startTime  | 2014-12-18T02:56:55.677Z                                                                      |
    +-------------+-----------------------------------------------------------------------------------------------+
    | @status     | running                                                                                       |
    +-------------+-----------------------------------------------------------------------------------------------+
    | @href       | https://p1v21-vcd.vchs.vmware.com/api/task/fe423f3b-3d8d-4fff-ba0a-491f052723db               |
    +-------------+-----------------------------------------------------------------------------------------------+
    | task:cancel | https://p1v21-vcd.vchs.vmware.com/api/task/fe423f3b-3d8d-4fff-ba0a-491f052723db/action/cancel |
    +-------------+-----------------------------------------------------------------------------------------------+
    |   Rule ID | Enabled   | Type   | Original IP      | Original Port   | Translated IP   | Translated Port   | Protocol   | Applied On   |
    |-----------+-----------+--------+------------------+-----------------+-----------------+-------------------+------------+--------------|
    |     65538 | True      | SNAT   | 192.168.109.0/24 | any             | 192.240.158.81  | any               | any        | d0p1-ext     |
    |     65537 | True      | DNAT   | 192.240.158.81   | 22              | 192.168.109.2   | 22                | tcp        | d0p1-ext     |
    |     65540 | True      | DNAT   | 192.240.158.81   | 8080            | 192.168.109.4   | 8080              | tcp        | d0p1-ext     |
    |     65541 | True      | DNAT   | 192.240.158.81   | 23              | 192.168.109.2   | 22                | tcp        | d0p1-ext     |
    

I hope you will find **vca-cli** useful. The project is under Open Source Apache2 license and on a public GitHub [repository](https://github.com/vmware/vca-cli). You are welcome to take a look and contribute. On future posts, I will cover other features of **vca-cli**.



