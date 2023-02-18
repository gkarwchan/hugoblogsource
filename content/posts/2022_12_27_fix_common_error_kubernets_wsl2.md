---
title: How to fix common error using Azure Kubernetes AKS from WSL2
date: 2022-12-27T19:43:59-07:00
tags: ["kubernetes-k8s", "aks", "azure" ]
---

When you use Kubernetes CLI tool: `kubectl` that is installed while you installed Docker Desktop for Windows, there is a small glitch that it will fail the `kubectl` commands, because of Kubeconfig file.

Let's supposed you want to create a new cluster on AKS, as follows:

```bash
az aks create --resource-group MyResourceGropu --name MyMicroserviceCluster --node-count 1 --enable-addons http_application_routing --generate-ssh-keys
```

And then you need to set that new cluster as your default cluster to work on, so you use 

```bash
az aks get-credentials --resource-group MyMicroserviceResources --name MyMicroserviceCluster
```

The previous command will retrieve the credentials of the newly created cluster and store it in the kubeconfig file, and make the newly cluster as the current default cluster, so any subsequent `kubectl` command will run against that cluster.  
If you run the previous command from WSL2 terminal, you will get the following message:  

```bash
Merged "MyMicroserviceCluster" as current context in c:\Users\<username>\.kube\config
```

Because Kubernetes CLI tool is installed with Docker Desktop for windows, so it default the config location to windows location.  
But later any subsequent `kubectl` command from WSL2 terminal, will use the linux path for kubeconfig which is `~/.kube/config`.   
So, if you run the following command:  

```
kubectl config current-context
```
you will see that the current context still the current context in linux config file, which most probably is the default **docker-desktop**.  

To fix the problem, you can specify the config file as environment variable **KUBECONFIG**.  
So modify the profile file **~/.profile** by adding the following:  

```bash
export KUBECONFIG=/mnt/c/Users/<windows user>/.kube/config
```
This will point the config file to the windows config file.
