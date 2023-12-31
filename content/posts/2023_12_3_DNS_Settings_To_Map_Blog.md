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



# Step by step on how to use DNS config to map your url:  

## But wait, there is no IP address?

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

### mapping to apex with Azure DNS
Azure DNS, and many other DNS providers support: `ALIAS`, `ANAME`, so to map apex domain is as easy as add `ANAME` record that map your custom domain to the storage url.  


## Summary:
So to summarize, to map to a subdomain (like blog.mysite.com), you just add a `CNAME` record in your DNS provider.  
To map the apex domain, either use a DNS provider that support `ANAME`, or forward your apex domain to `www` subdomain, and then map the `www` subdomain.


