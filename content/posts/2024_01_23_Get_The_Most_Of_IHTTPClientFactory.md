+++
title = "Best practices of calling HTTP from Asp.NET Core"
date = 2024-01-23T10:41:54-06:00
short = true
toc = true
tags = ["asp.net"]
categories = []
series = []
comment = true
+++

[I described before how IHttpClientFactory solved the Socket Exhaustion problem]({{< ref "2023_01_08_Http_And_Socket_exhaustion.md" >}}).  
But IHtpClientFactory has lots of other benefits which can help you build resilient Http consumer. We are going to talk about them here.  


