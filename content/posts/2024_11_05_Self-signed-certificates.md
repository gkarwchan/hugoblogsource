+++
title = "Self certified certificates"
date = 2024-11-05T18:41:54-06:00
short = true
toc = true
draft = false
tags = ["security"]
categories = []
series = []
comment = true
+++

A self-signed certificate is a type of SSL/TLS certificate that is generated and signed by the individual or organization that owns it, rather than being issued by a trusted Certificate Authority (CA). It is used inside development process to use https on your development server or on developer machine.



# Generate self-signed :

```bash
# Generate private key
openssl genrsa -des3 -out myCA.key 2048
# Generate root certificate
openssl req -x509 -new -nodes -key myCA.key -out myCA.pem

# Or you can do it in one statement
openssl req -nodes -new -x509 -keyout server.key -out server.cert
```

Where in the provious code:

* -nodes: Generates a private key without password protection
* -new: Generates a new certificate.
* -x509: Use X.509 format
* -keyout: Specifies the file name for the key.
* -out: Specifies the file name for the certificate

The previous comand will prompt for information like country, state, ...  
Make sure when it comes to specify the **`DNS name`** to use **`localhost`**.  

Alternativley you can specify all the details as follows:  

```bash
openssl req -nodes -new -x509 -keyout server.key -out server.cert \
-subj /CN=localhost/O=home/C=US/emailAddress=me@mail.internal \
-addext "subjectAltName = DNS:localhost,DNS:web.internal,email:me@mail.internal" \
```

After running the previous command, it will generate two files:  

* server.key: the private key.
* server.cert: the certificate.

Now you can use it in NodeJs as follows:  

```bash
npx http-server -S -C server.cert -K server.key -p 8080
```

using Powershell
```powershell
New-SelfSignedCertificate -NotBefore (Get-Date) -NotAfter (Get-Date).AddYears(5) `
-Subject "CN=localhost" -KeyAlgorithm "RSA" -KeyLength 2048 `
-HashAlgorithm "SHA256" -CertStoreLocation "Cert:\CurrentUser\My" `
-FriendlyName "HTTPS Development Certificate" `
-TextExtension @("2.5.29.19={text}","2.5.29.17={text}DNS=localhost")
```

mkcert

https://github.com/FiloSottile/mkcert

