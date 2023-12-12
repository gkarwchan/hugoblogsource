+++
title = "Making sense of SSL, RSA, X509 and CSR"
date = 2016-04-18T23:42:00.001-06:00
short = true
toc = true
tags = ["security"]
categories = []
series = []
comment = true
+++

This is the second part of learning about SSL/TLS.  
[The first part was how to protect the site with SSL]("https://www.ghassan.page/posts/2016_03_11_secure_your_application_with_ssl/").  
This part is about explaining more the terms, technologies, protocols, standards used in SSL.  
## What is SSL/TLS:
`SSL` is the standard protocol to secure the communication between a web server and a browser, by creating an encrypted link between the two.  
`SSL` last version was 3.0, and TLS  succeeds SSL, and become the new standard. But still some components of the protocols have the name SSL, like SSL certificate for example, so when you see the name SSL it most probably means the new TLS, because SSL is rarely used any more.  
  

## SSL/TLS workflow and TLS Handshake:
When a browser hits the web server using the **`HTTPS`** protocol, it start a process of creating an encrypted session between the two.  
At the beginning, the encryption used is public-key encryption, which is an asymmetric type encryption.  
The web server has a couple of keys public and private. It sends the public key to the browsers, and the browsers use the public key to encrypt the communications later.  
Only the web server can know how to decrypt the communication.  
Because the public key decryption is slow and expensive, so the web server and the browser will switch to symmetric encryption where only one key is required.  
They negotiate between each other on what the best encryption algorithm they should use. The algorithm used would depend on the server and the browser.  
This negotiation phase is called TLS handshake.  

## Protocols, standards and concepts used in SSL

### 1. Public key encryption RSA:
As we mentioned the server that implement `SSL` has pair of keys, public and private, which are used during the TLS handshake.   
The most common public key encryption used in SSL is the **`RSA`**`.  
In `OpenSSL` tools, the `RSA` is the default option when generating a public/private key.  
To generate key pairs with OpenSSL, we generate first a private key, then generate a public key depending on the private key.  
Example of generate a private key: 
```bash
openssl genrsa -out {private-key-filename} 2048
```
The 2048 is the size of the private key, which is now a days considered the appropriate secure size. Less than 2048 is not secure, and bigger than 2048 will be slow to process.  
To extract a public key from the private key : 
```bash
openssl rsa -pubout -in {private-key-filename} -out {public-key-filename}
```

### 2. PEM Protocol
When we generate the keys in the previous example, the generate files will contains data like this:  
> "-----BEGIN PRIVATE KEY-----  
MIIEczCCA1ugAwIBAgIBADANBgkqhkiG9w0BAQQFAD..  
AkGA1UEBhMCR0IEzARBgNVBAgTClNvbWUtU3RhdGUxFDASBgNVBAoTC0..  
0EgTHRkMTcwNQYD  
......  
......  
It8una2gY4l2O//on88r5IWJlm1L0oA8e4fR2yrBHX..adsGeFKkyNrwGi/  
7vQMfXdGsRrXNGRGnX+vWDZ3zWI0joDtCkNnqEpVn..HoX  
-----END CERTIFICATE-----"  


This format called **`PEM`** format, stands for **`Privacy Enhanced Mail`**.  
`PEM` is a text representation of the real binary key in `DER` format (**`X.509 ASN.1 key`**), it is base64 encoding of the DER binary format.  
We could store the binary version of the file only with **`DER`** encoding, but the most common way is the PEM version.  

### 3. Digital Identity
As a user, in order to trust a web site for your precious information, you need to trust the web site owner.  
Similarly, if you receive an email, you want to trust that the email you received was sent by the email owner, and not hacked by anyone else.  
In real life, we have our identity card, which is a trusted document issued by a trusted authority (the government) which is a prove of our identity.  
The industry came up with similar policies and standards to handle the digital identity.  
### 4. Public Key Infrastructure (PKI) and Certificate Authority (CA):
The `PKI` is the infrastructure that the industry created to manage the digital identities.  
The PKI created a hierarchical body of many organizations which their role is to issue digital identities.  
These organizations called `Certificate Authority (CA)`, and when you want to protect your site with `SSL/TLS`, you have to communicate with them, and they have to follow up with you to make sure that you are a legitimate company, and you are who you want to claim you are.  
The digital identity has many four types ranked depending on their security level and how much investigation the `CA` will do before they submit a certificate.  
Please find out these types in my previous post.  

### 5. Digital Certificate (X.509)
As we discussed before, SSL required the web server to have public key, and a digital identity, to give to the browsers.  
The industry decided to combine these two in one file, which is called : digital certificate, or `SSL certificate`.  
PKI policies defined the format for this certificate in a standard called **`X.509`** 
The Certificate format X.509 v3 contains:  
1. Version Number.
2. Serial Number. 
3. Signature Algorithm ID.
4. Issuer Name.
5. Validity period: 
    1. Not Before.
    2. Not After.
6. Subject name.
7. Subject Public Key Info:
    1. Public Key Algorithm
    2. Subject Public Key 
8. Issuer Unique Identifier (optional).
9. Subject Unique Identifier (optional)
10. Extensions (optional)  
...  
11. Certificate Signature Algorithm
12. Certificate Signature

### 6. CSR: Certificate Signing Request:
The certificate is issued by one of CA(s), and in order to get a certificate you have to contact one of the CA(s) and send them a request in the format: CSR (Certificate Signing Request).  
The CSR is a PEM formatted file with the following information:   
* Common Name
* Organization
* Organizational Unit
* City
* State/County/Region
* Country
* Email Address
* Public Key.  
You can generate a CSR by either doing it from a web server, or using openssl tools like the following: 
```bash
openssl req -new -sha256 -key privatekey.key -out request.csr
```
When you run the previous command, it will prompt you to enter all the CSR details and will generate a CSR file for you.
