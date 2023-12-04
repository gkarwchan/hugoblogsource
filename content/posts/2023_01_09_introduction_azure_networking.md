---
title: A developer introduction to cloud networking
date: 2023-01-08T20:07:36-07:00
tags: ["azure", "networking"]
---

As a developer who dealt with the cloud, either to create a virtual machine, or to deploy a website that connect to a database, then most probabely you had to deal even in short with a private network.
And most of us developers don't know a lot about networking, because it is either the job of dev-ops or system administrator. But on the cloud you find that you have to take some decisions related to the networking.
This post is an introduction for developers who know very little about the cloud, and will cover enough information to help you understand how to take better decisions.

### Introduction to private networks:
Amazon has the Virtual Private Cloud (VPC), and Azure has its equivalent the Virtual Network (VN). Both let you isolate many resources (databases, file storage, API servers….) into their own private network that is protected (not accessible) from the outside, and they can securely communicate with each others, even they can communicate securely with on-promises networks. As well, you can create a segment of that network to communicate to the outside world.
Both VPC, and VN are using the networking technique called [Private Network](https://en.wikipedia.org/wiki/Private_network) which the [Local Area Network LAN](https://en.wikipedia.org/wiki/Local_area_network) is just one implementation of it.  

### What is a private network?
Private Network, is a network that uses private IP address space, which provides these essential functionalities to the network:
* Help in the shortage of IP addresses on IPV4, by re-using the same address range of other private networks.
* Isolate and protect your resources from outside. For example, you want your cloud database to be isolated, and accessible only from your web server.
* Segment your own virtual network, into one or more subnets, so you can isolate your own resources to not communicate with each others.  

### How does a private network work?
When we build a private network, we choose a range of private network addresses, and we should select one of the available address ranges available for private networks.
Internet Assigned Numbers Authority (IANA) reserved the following IPv4 address ranges for private networks. (P.S: if you heard the term [RFC1918](https://tools.ietf.org/html/rfc1918) then it is the protocol that reserves these addresses).
 
* 192.168.0.0 - 192.168.255.255 (65,536 IP addresses)
* 172.16.0.0 - 172.31.255.255 (1,048,576 IP addresses)
* 10.0.0.0 - 10.255.255.255 (16,777,216 IP addresses).  

We can do a better representation of these addresses with [CIDR format](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)

 
| IP address range | number of addresses | largest CIDR block (subnet mask)  |
|---|---|---|
| 10.0.0.0 – 10.255.255.255 | 16777216 | 10.0.0.0/8 (255.0.0.0) | 
| 172.16.0.0 – 172.31.255.255 | 1048576 | 172.16.0.0/12 (255.240.0.0)  |
| 192.168.0.0 – 192.168.255.255 | 65536 | 192.168.0.0/16 (255.255.0.0)  | 


To learn more about CIDR please read [its wikipedia page](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing)

This is why when you try to find your local IP address through Windows’s *`ipconfig`*, or Linux’s *`ifconfig`*, you will get an address from the ranges above.

### Private Network and NAT ###
In order to allow resources (such as computers) on a private network communicate to the external internet, there is a method called Network Address Translation 
(NAT), or Port Address Translation (PAT), which is based on a “routing device”  (like your home router) that will translate a large number of these private IP addresses to a single public IP address. It does so by mapping each internal/private IP address to the public IP address and a specific port (as usually defined in the TCP or UDP protocols). This way, you can have a network containing multiple devices (e.g. 10.0.0.1, 10.0.0.2, 10.0.0.3, etc), and they will all be represented by the single router with a public IP address (e.g. 11.32.123.4).

#### Exercise on NAT in action ####
To see the NAT or PAT in action, you can test it on your local home router.
If you have more than one device in your own home (Laptop, mobile, tablet..), then try find your local private IP address by either using of the these commands:
Windows’s ipconfig
POSIX’s ifconfig

Or on the mobile, you can go to the settings and check your ip address.
You will find an address from the range mentioned in the table obove.

To find your external IP address, go to the website [https://www.whatismyip.com](https://www.whatismyip.com/).
You will find a different IP address, which is the IP address that your ISP assigned to you.

