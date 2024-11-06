+++
title = "Secure your web site with SSL/TLS"
date = 2016-03-11T08:59:00.002-07:00
short = true
toc = true
tags = ["security"]
categories = []
series = []
comment = true
+++

SSL (Secure Sockets Layer) and its successor, TLS (Transport Layer Security), are cryptographic protocols that secure internet communication by encrypting data between a client (like a browser) and a server.

# How SSL/TLS works?
SSL/TLS secure communication by:  

* Encryption: Ensures that data transmitted between the client and server cannot be read by third parties.
* Authentication: Verifies the identity of the server (and sometimes the client), establishing trust.
* Data Integrity: Guarantees that data has not been altered during transmission.

# How to do it?

In order to secure the web site with SSL, you first need to buy a certificate.  
A certificate is a document that your website will send back to the browsers as an **`Official identification`** for your web site, and your business.  

The certificate is issued by certified companies who are called **`Certificate Authorities`**`.  

## Types of SSL Certificates:  
First of all you have to decide which certificate type you should chose for your web site. There are three types:  
* **Domain Validation (DV) SSL Certificate**: This is the simplest type of certificate, where the `CA` checks only that the applicant owns or has the right to use the domain name.  
* **Organization Validation (OV) SSL Certificates**: The `CA` checks more about the company owns the domain name, and display more information about the company owns the domain.  
* **Extended Validation (EV) SSL Certificate**: The `CA` conducts a thorough check on the organization with some standard guidelines defined by the industry. This is usually required for organizations that require to have payments managed by on their own website and their own software.  

## How to buy a certificate: 
After you decided what type of certificate you want to buy, you search for a suitable `CA` authority to buy your certification from. The `CA` authority requires from your side a request called **`Certificate Signing Request`** (CSR).  
There are many ways to generate the CSR. I will describe the process using [OpenSSL tools]("https://www.openssl.org/").  

First you need to generate a private key:  
```bash
openssl genrsa -out domain.com.key 2048
```
And then create the CSR:
```bash
openssl req -new -sha256 -key domain.com.key -out domain.com.csr
```
This will generate the CSR file, which you will send to the CA authority, which in return will send you the certificates.

