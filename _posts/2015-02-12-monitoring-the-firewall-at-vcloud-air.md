---
layout: post
title: Monitoring the Firewall at vCloud Air
comments: true
permalink: /monitoring-the-firewall-at-vcloud-air
---

vCloud Air accounts provide a pretty sophisticated virtual data center where users can create virtual machines. Protecting the access to the virtual data center, there is a feature-rich edge gateway that includes a firewall. In some cases it is necessary to monitor the activity of the firewall. The following article shows how to configure the firewall to send logging messages to a syslog server.

Monitoring firewall logging is critical when something is not working as expected, for example when a set of rules are not filtering the traffic the way we think it should.

For capturing the firewall logs, we need to:

1. configure a syslog server
2. configure the edge gateway to send logging messages to the syslog server

On my previous [article](http://blog.pacogomez.com/quick-and-easy-provisioning-at-vcloud-air/), I described how to setup an Ubuntu server in just a few commands. We can use the same steps to provision our syslog server.

Once the server is up and running, make a few changes to the **/etc/rsyslog.conf** file (these steps assumes Ubuntu 12.04):

    
    # uncomment the lines
    $ModLoad imudp
    $UDPServerRun 514
    
    # add to the end
    $template TmplAuth, "/var/log/%HOSTNAME%/%PROGRAMNAME%.log"
    

Then change permissions to /var/log and restart rsyslog service:

    
    $ sudo chown syslog:syslog /var/log
    
    $ sudo service rsyslog restart
    

Test if the service is ready by entering:

    
    $ nc -w0 -u 127.0.0.1 514 <<< "testing 123"
    
    $ tail /var/log/syslog
    

Now the fun part. With the [vca-cli](https://github.com/vmware/vca-cli), connect to your virtual data center, get the IP address of the syslog server and configure the edge gateway to send the logging messages to the syslog server. Assuming you have the right values for INSTANCEID and VAPPNAME, just enter the following commands:

    
    $ vca login email@company.com --instance ${INSTANCEID}
    
    
    $ IP=`vca -j vm --vapp ${VAPPNAME} | jq -r '.vms[0].IPs[0]'`; echo $IP
    
    192.168.109.2
    
    
    $ vca gateway set-syslog --gateway gateway --ip $IP
    
    | Start Time          | Duration      | Status   |
    |---------------------+---------------+----------|
    | 2015-02-12 21:58:38 | 0 mins 8 secs | success  |
    
    
    $ vca gateway
    
    Edge Gateways:
    | Name    | External IPs       | DHCP Service   | Firewall Service   | NAT Service   | Internal Networks          | Syslog        |
    |---------+--------------------+----------------+--------------------+---------------+----------------------------+---------------|
    | gateway | ['107.189.93.162'] | On             | On                 | On            | ['default-routed-network'] | 192.168.109.2 |
    

And you are all set, tail the **/var/log/syslog** file on the syslog server to start reading those pesky log messages.


### Summary

vCloud Air On Demand provides a sophisticated edge gateway with firewall, NAT server and tons of other features. The process described here allows to configure a syslog server to capture and analyze the firewall log messages, validate firewall rules, debug configuration issues and perform general monitoring.
