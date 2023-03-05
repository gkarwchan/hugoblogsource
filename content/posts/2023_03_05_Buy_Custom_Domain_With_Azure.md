---
title: Buy Custom Domain With Azure for your App Service.
date: 2023-03-04T21:44:55-07:00
tags: ["azure", "networking"]
---
If you googled how to buy a domain name on Azure, you might get answers saying that Azure doesn't provide domain name registrar, like [the following answer](https://learn.microsoft.com/en-us/answers/questions/10805/use-azure-as-a-domain-registrar-for-a-domain-curre?orderby=helpful), or [the following discussion](https://feedback.azure.com/d365community/idea/9e9f97ea-8526-ec11-b6e6-000d3a4f0789).  
Not even those answers, even the book [Exam Ref AZ-900](https://www.microsoftpressstore.com/store/exam-ref-az-900-microsoft-azure-fundamentals-9780137955145) which is a Microsoft book says the following about `Azure DNS Zone`:  
> If you want to purchase your own domain name, you go to a domain registrar, and they register the domain to you. ....  
  

The book didn't mention a way to buy your domain from Azure itself.  
I struggled with that myself, and bought my domain with a third party provider. But it turned out Azure provide this service already.  
This is why I hope you will come to my post and find the answer you are looking for.  

## Custom domains with App Service Domain Service:

To buy a custom domain through Azure, you need to create an **`App Service Domain`** resource in Azure.  
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/qqcugjwb9nkq930i7aje.jpg)
When you create the resource, you will enter the domain name you want, and Azure will find out if you can use it or not.  

![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/r2xxabp5t04qiy6kthyy.jpg)

Right now, as I am writing this post, only these `Top Level Domain` (TLD) are available through Azure:  
* .com
* .net
* .co.uk
* .org
* .nl
* .in
* .biz
* .org.uk
* col.in

## Why you need to buy from Azure?
The obvious answer to this question, is you have one place to manage your site content, and its domain name and its SSL certificate.  
But beside that, Azure is **cheeeeeap**. The pricing right now is only $11 US dollar for the whole year.  
I don't know what you are using for as your domain provider, but I am using GoDaddy, and I am paying for the domain and SSL certificate $10/month.  
And on top of that the SSL certificate is free (if you are using standard domain like www.somesite.com). You have to pay for wildcard certificates.  

