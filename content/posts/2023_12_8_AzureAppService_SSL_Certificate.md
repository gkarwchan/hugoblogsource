+++
title = "Different options to add SSL certificate to you Azure App Service"
date = 2023-12-08T12:41:54-06:00
short = true
toc = true
tags = ["azure", "security"]
categories = []
series = []
comment = true
+++

To add a SSL certificate to your web app hosted on Azure App Service with a custom domain, there are few options. I am going to list them here.



## Free certificate:  
Azure provides a free SSL certificate, and it is fully managed by Azure.  Azure renew the process for you, and take care of everything for you.  
Although having a free certificate is a wonderful idea, but it has some shortcoming:  
1. you have no control over it, and you cannot export it to use it somewhere else.  
2. This certificate can only be used by the associated App Service and nowhere else even inside Azure.  
3. As well it works only for a single subdomain, and cannot be a wildcard for all subdomain.  
4. Another issue with this certificate that upon writing this post, this certificate doesn't support `Extended Validation` which provides another layer of trust.  
  

For all these previous issues you might consider buying your own certificate.  

## Azure App Service Certificate:
Azure provides you with a way to buy the certificate from a `Certificate Authority` (CA) provider, but through Azure itself.  
Azure uses (upon writing this post) GoDaddy CA provider, and Azure communicate with GoDaddy to issue the certificate and retrieve it into Azure.  
The benefits of that is Azure is going to be responsible of configure the certificate and use it in the App Service, and at the same time take care of renewing the certificate.  
It is exactly like you buy it yourself from GoDaddy, but it is managed through Azure.  
You can as well export it and use it somewhere else because it is exactly like you buy it yourself.  

