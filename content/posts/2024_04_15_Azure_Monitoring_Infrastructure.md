+++
title = "Azure Diagnostics/Monitor Infrastructure"
date = 2024-04-15T10:41:54-06:00
short = true
toc = true
draft = true
tags = ["azure"]
categories = []
series = []
comment = true
+++

Azure has a built-in infrastructure for diagnostic and log all its services. It is off-the-shelf feature that you get it with all the services you are using.  
It monitors and logs different areas of the running servies, and can send those logs to the destination you want.  

# Sources of diagnostic data:
Each Azure service or resources has its own type of diagnostic data and metrics that we can collect from it, but we can categorize them in three different categories:  
1. Platform Metrics: They are various performance indicators and health indicators that related to the service. Those are sent automatically to Azure Monitor Metrics.  
Each service has its built-in platform metrics and you can find that for each service [here](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/supported-metrics/metrics-index?source=recommendations).

2. Platform logs: Those are detailed diagnostic and auditing information by Auzre resources. They are different for each service type, and they are the exceptions, errors that are auto-collected from the running service.
3. Activity log: which are logs for any changes that applied to the services, which are applied by the resouce owner or contributer.

# Destinations:
You can setup 