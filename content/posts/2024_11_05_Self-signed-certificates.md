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
We will see how to generate self-signed certificate using:  

1. .NET Core tool
2. Powershell
3. OpenSSL
4. tool called mkcert

## With .NET Core tool:

The .NET Core SDK includes an HTTPS development certificate, and it works with `Kestrel` and `IIS express`.  
You need first to trust it:  

```bash
## this will trust the development certificate coming with .NET
dotnet dev-certs https --trust

## the next command check if you already have a valid certificate and if trusted
dotnet dev-certs https --check --trust

## the following will check if there is a certificate, 
## if not, it will create one
dotnet dev-certs https
```

#### Where the certificate is stored?
In Windows the certificate is stored in the current user certificate store (the Windows registry). You can access it by running Microsoft Management Console (MMC) and add `certificate` snap-in.



## With PowerShell

```powershell
# the following command create a certificate for localhost address, and store it in local machine store, under personal store
$cert = New-SelfSignedCertificate -DnsName @("localhost", "localhost") -CertStoreLocation "cert:\LocalMachine\My";
```


## With OpenSSL

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

## using tool called mkcert
mkcert: https://github.com/FiloSottile/mkcert
This tool does more to create certificate. It create a local **`CA`** (Certificate Authority), and generate a certificate and store it in the system store, and one more benefit, it store the certificate in firefox store, where the above commands will not work with firefox and you have to create a policy file to trust the generated certificate.

