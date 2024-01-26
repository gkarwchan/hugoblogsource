+++
title = "Everything you need to know about configure DNS to provide domain for your blog"
date = 2023-12-03T12:41:54-06:00
short = true
toc = true
tags = ["azure", "networking"]
categories = []
series = []
comment = true
+++

You host your blog on Github pages, or Azure static website, or Azure blob storage with static website enabled.  But you need to use a custom domain.  
Every time I changed my content location, I go back to remember how to do it, so I decided to make a post about it.  

# Understand how custom domain mapping works:
You host your static web pages on one of the static hosting services, for example these three: 

* github pages: free service as long as your repo public.
* Azure static web site: free with 0.5 GB storage.
* Azure storage account: cost depends on the storage.

But those services host your data on their own URL.  
For example these are the typical urls for those services:  

* for github pages: **{account}.github.io**
* for Azure static web site: {sitename}.azurestaticapps.net
* for storage account web hosting: {accountname}.z22.web.core.windows.net.  

so you need to use your DNS provider to map your domain name to their url.

### But wait, there is no IP address?

For static web app that is hosted on `azure blob storage`,  `github pages`, or `azure static web app`, there is no IP address, but there is a url, so we need to map the url to another url. 

### Map url to another url using `CNAME` record in DNS:
DNS mainly is used to map IP address to a domain, but it is possible to map a url to a custom domain, using `CNAME` record.  

`CNAME` record is used to map your domain to a different url, to get its content from there.  
Which means in your DNS provider (registrar), you need to add a `CNAME` record, that point the url of the content to your custom domain.  

But there is one small problem. `CNAME` works only for subdomain.  
So if you want your blog or website to be hosted under something like: blog.mysite.com, or even www.mysite.com then you are good to use `CNAME`.  

But what if you want to use  the `naked domain` or `apex domain` like: mysite.com?

Then the process will be different depending on your DNS provider.  

### Mapping apex domain to another domain.
In old DNS protocol, apex domain (or the naked domain) can be mapped only to an IP address using `A` record.  
There is no way in old DNS that will map the apex domain to a different url.  
But later DNS developed and added new records in order to do that feature. They added these records:  

* `ANAME`: Will work as `CNAME` by pointing to a URL, but can work on the apex domain.
* `ALIAS`: Is a DNS way for forwarding.
* `CNAME flattening`: is another mechanism of using CNAME to map to apex.  

But the sad story is not all DNS providers support the above records. For example GoDaddy, and Google both don't support this feature.  
So how you do support that feature if you are using those DNS?  
The answer is either move to a better DNS provider, like Azure DNS service?  
Or you forward your apex domain to www subdomain.

But wait, isn't forwarding the same as `CNAME` mapping subdomain?  
### Forwarding vs. CNAME mapping:
Forwarding is responding with 302 HTTP status and forward your browser url itself, so you will see the new URL in the browser.  

But `CNAME` mapping is serving the content from the mapped url, but the browser url still the same. 

> **PS**: Browsers hides the `www` subdomain to simplify the address bar and because it used to be the default subdomain. So even you have been redirected from apex to www subdomain but your browser still showing the apex.  

> **PS**: Even you can serve your site from apex domain, but as a security best practice is always good to secure your www subdomain, and either you do forwarding or reserve it to server something else from your website.

> **Another fun fact**: historically all domains served their content from www subdomain to distinguish them from `ftp` and `mail` subdomains. But later the use of ftp become less common, so many companies now serve their content from the naked domain.

# Step by step how to do it?

### Map subdomain (www) to the host url:

You need to create a `CNAME` record in your DNS provider (registrar). All DNS providers support CNAME.  
You need to provide the following when you create a new record:

1. Type: CNAME
2. Name: the subdomain, for example **www**
3. Value: is the url of your blog host.

> PS: DNS changes might take to 24 hours to take effect.  

So now, anybody visiting your custom subdomain, will get the contents hosted in those host services.  

But wait, you need to do it in the opposite direction as well. So anyone who visit the host url will be redirected to the new custom domain.  
So for those host, you refer to how to do it.  
One more point. It is important you first do the mapping from the host to custom domain and then change the DNS record in your DNS provider.  

### mapping to apex domain.
If you need to use apex domain, then you have to use `ANAME`, `ALIAS` or `CNAME flattering` if your DNS provider support them. So for example using Azure DNS: 

#### mapping to apex with Azure DNS
Azure DNS, and many other DNS providers support: `ALIAS`, `ANAME`, so to map apex domain is as easy as add `ANAME` record that map your custom apex domain to the host url.  

#### mapping with other DNS 

If your DNS doesn't support them, then you can do the following:  

For github pages only, github provide a solution by providing the IP addresses of the Github Pages Server.  
So for github pages, you add an `A` record, which is a record that map IP address to domain name, and the IP address is the addresses for GitHub Pages servers, which is as follows:

```
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```

For no github pages, you need to create a forward rule in your DNS provider, which redirect your apex domain to the www subdomain.  


### Domain Verification:  
In order to prevent other people host their content on a subdomain of your custom domain, a verification process has to be done.

The verification is achieved by adding a `TXT` record in your DNS provider.  
`TXT` record is like a secret password that you add it to your DNS and associated with your domain, and the host service will query that value to make sure that your are the owner of that custom domain.  
So the host provider will give you an arbitrary generated string which you added as `TXT` record.  
After you add that value in your DNS domain records, you go back to the host provider and validate that value.  
Each host provider has its own interface to validate that value.  
> PS: it might take 24 hours for that `TXT` record to take effect.  


## Summary:
So to summarize, to map to a subdomain (like blog.mysite.com), you just add a `CNAME` record in your DNS provider.  
To map the apex domain, either use a DNS provider that support `ANAME`, or forward your apex domain to `www` subdomain, and then map the `www` subdomain.


