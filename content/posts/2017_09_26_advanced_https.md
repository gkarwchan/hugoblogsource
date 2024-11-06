---
title: Advanced HTTP
date: 2017-09-26T19:51:56-07:00
tags: ["security"]
---

Adding an SSL Certificate and enabling HTTPS on your web site is not the end of the road for securing your website, and securing the communication to your website.  
It is just the start, and you need to do more steps related to HTTPS to guarantee your site safety, and your visitor safety.  
In this post I am going to describe:

1. TLS and its algorithms in more depth.
2. Insecure protocols, and algorithm.
3. Best algorithm combination.
4. Redirect from HTTP using HSTS.

## Introduction
If you want to learn more about HTTPS and its basic concepts, I wrote two posts about:
1. [Creating an SSL Certificate]({{< relref 2016_03_11_Secure_your_application_with_ssl >}}).
2. [SSL/TLS terminologies]({{< relref 2016_04_18_making_sense_of_ssl_rsa_x509_and_csr >}}) that cover lots of basic knowledge on that subject.  
I recommend reading them to know the basic and how to implement HTTPS on your web site.  
After enabling HTTPS on your web site, you should do the following:  

1. disable insecure protocol SSL 3.0.
2. either disable TLS 1.0 or disable all insecure algorithms.
3. disable ciphers that are insecure.
4. redirect from http to https using HSTS.

## TLS Releases
TLS protocol keeps developing and enhancing its security. The newer versions are better and more secure and more difficult to break than the older ones, and older versions become less secure or even insecure.  
Old versions like TLS 1.0 and all SSL are considered insecure nowadays.  
This is a table of TLS releases and its status.

| Protocol Version | Security Status |
| --- | --- |
| SSL 2.0 | Insecure |
| SSL 3.0 | Insecure |
| TLS 1.0 | Depends on configuration |
| TLS 1.1 | Depends on algorithm |
| TLS 1.2 | Depends on algorithm |

### What TLS version my website support?

How do you know what TLS protocols your website is supporting?  
If you are developing on Windows/IIS, then (as my knowledge goes back only to Windows Server 2008), as long as you have Windows Server 2008 Service Pack 1, and higer, then you are having up-to-date TLS 1.2.  
If you are developing NodeJs, or Go language website, on a Linux operating system, then NodeJs, and Go are using OpenSSL software, and if you have if you are updating your server regularly (as you should), then you have TLS 1.2.  

### Which protocol version is being used?
When a browser visit your website, there is a process called TLS handshake, where the web server and the browser will find what is the highest TLS protocols that both support, and they will use it.

### Disable SSL protocols 2 & 3
As we mentioned SSL 2.0 and 3.0 are insecure, and we should disable them permenantly.  
SSL insecurity was very serious, that triggered Web servers, and browsers to disable it permenantly.  
Here is a list of when major web browsers disabled SSL 3.0:  

| Web Browser | Version | Release Date |
| --- | --- | --- |
| Chrome | 40 | January 2015 |
| Firefox | 35 | January 2015 |
| Explorer | 11 (patches) | January 2015 |

For the web server side, I am covering NodeJS or Go language on Linux server, and IIS solutions on Windows Servers. If your solution is not one of these, refer to [this website](http://disablessl3.com/) to find a solution.

#### NodeJS & Go on Linux
if you are doing NodeJs or Go language website, then you are using `OpenSSL`.  
Even your Linux regular update should take care of it, but double check that you have the proper OpenSSL version:  

* OpenSSL 1.0.1 users should upgrade to 1.0.1j.
* OpenSSL 1.0.0 users should upgrade to 1.0.0o.
* OpenSSL 0.9.8 users should upgrade to 0.9.8zc.
* OpenSSL 1.0.2 users are laughing.

But still you can have this line of code to make sure your web server won’t fallback to SSL if the browser (a melicious user) requested that.

#### IIS and Windows Server

Edit the Windows Registry as follows:
```bash
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server]
"Enabled"=dword:00000000

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server]
"Enabled"=dword:00000000
```

### What about TLS 1.0?
Some consider TLS 1.0 is insecure, and it is better to disable it, but there is one problem with disabling TLS 1.0, which is IE before 11, and I mean IE 8 to 10 have TLS 1.1 disabled by default, and only TLS 1.0 is enabled by default.  
If you don’t care to support IE before 11, then it is better to disable it on your website, and in case you have to support old IE, then you have no choice but to disable all vulnerable ciphers in TLS 1.0.  

### How bad TLS 1.0?
I am not a security expert, but according from my modest knowledge, the biggest weakness of TLS 1.0 is that it include a means by which can downgrade to SSL 3.0, and that TLS 1.0 cryptographic initialization being predictable in some implementation, which means if someone with millions of dollars will dedicate to crack your HTTPS to force it to downgrade.

### TLS algorithms
TLS protocols define suite of algorithms to encrypt the data, and these algorithms can be categorized in three categories:

1. Key exchange or key agreement.
2. Ciphers.
3. Data integrity.

### Key exchange
Key exchange are the inialize the handshake to decide on the next phase of cipher that will be used.  
Some of the secure algorithms: 
* RSA
* DHE-RSA
* ECDHE-RSA
* ECDHE-ECDSA
* Kerberos.

And some of insecure algorithms: 

* DH-ANON
* ECDH-ANON.

### Chiphers

Ciphers are the main encryption algorithms.  
Some of the secure algorithms: 

* AES
* Camellia
* SEED.

And some of insecure algorithms: 

* IDES
* 3DES
* DES
* RC4.


### Data Integrity

Secure algorithms: SHA256/384.  
Insecure algorithms: MD5, SHA1.  

### Disable insecure algorithms in NodeJs

To disable insecure algorithms in nodejs, we specify the list when we initialize the https server.
We pass the options `ciphers` as follows:

```javascript
var server = https.createServer({
    key: privateKey,
    cert: certificate,
    ca: certificateAuthority,
    ciphers: "ECDHE-RSA-AES128-SHA256:!RC4:!HIGH!MD5",
    app);
```

The ciphers is a string of sub-strings separated by colon **`:`** which enable or disable an algorithm.  
If the sub-string start with **`!`**, then it means disable.  
So, in the previous example I am disabling MD5, RC4, and HIGH.
A common practice is to specify the three types of algorithms (key exchange, cipher and data integrity) in one string seperated by **`-`**.  

So, in the previous example: “ECDHE-RSA-AES128-SHA256” means use ECDHE-RSA for key exchange, and AES128 for cipher, and SHA256 for data integrity.  

This is a list that will let you pass [SSL labs](https://www.ssllabs.com/ssltest/) test with A+:

```javascript
[ 'ECDHE-RSA-AES128-GCM-SHA256',
  'ECDHE-ECDSA-AES128-GCM-SHA256',
  'ECDHE-RSA-AES256-GCM-SHA384',
  'ECDHE-ECDSA-AES256-GCM-SHA384',
  'DHE-RSA-AES128-GCM-SHA256',
  'ECDHE-RSA-AES128-SHA256',
  'DHE-RSA-AES128-SHA256',
  'ECDHE-RSA-AES256-SHA384',
  'DHE-RSA-AES256-SHA384',
  'ECDHE-RSA-AES256-SHA256',
  'DHE-RSA-AES256-SHA256',
  'HIGH', '!aNULL', '!eNULL',
  '!EXPORT', '!DES', '!RC4',
  '!MD5', '!PSK', '!SRP', '!CAMELLIA', '!3DES'
  ].join(':')
  ```

  ## Redirect from HTTP to HTTPS & HSTS

You need to provide a redirection from your website from http to https, so when the user visit your website without specifying the https, will be directed to https.  
The more traditional way, is to build an HTTP redirect (301), either in your application, or through the web server.  
All web servers: IIS, Apache, NGINX.. have a way to do that indirection.  

### HSTS
There is a new way emerging, and it is more secure than the 301-redirect: HSTS (HTTP Strict Transport Security).  
The only complication with it that it requires both Browsers, and web servers to support it.  
As most modern browsers support it, so you can count on it.  
When an agent visit an http address, it respond with a result with a header field named **`Strict-Transport-Security`**.

```http
Strict-Transport-Security: max-age=31536000
```
