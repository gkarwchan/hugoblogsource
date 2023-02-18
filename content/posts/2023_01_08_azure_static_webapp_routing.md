---
title: SPA routing and how to handle it with Azure Static Web app.
date: 2023-01-08T19:58:31-07:00
tags: ["azure static web app"]
---

If you built a SPA application using one of the modern SPA frameworks like React, Vue, Angular..., then you must be using their router to define your client side routing.  
But you need to make a small adjustment on the server that serve your static application in order to deal with client routing gracefully, and this small adjustment is to tell the server to have a fall back on any route that is not recognized by the server to the root of the application.  

I am going to explain more on that, and will explain in details why we have an issue, and how other platform fix it.  
But for the people who already know the details about SPA routing and they know the server has to accommodate for SPA routing, and they just need a fix on Azure Static web app, and want a fix for routing, then I am going to describe the solution first, and if you are interested more on knowing how and why, then continue reading this post.  

## How to fix it on Azure Static Web App:  

We fix it by creating a **`fallback route`** (which is a url to fall back to, when the server won't recognize a route).  
To create a fallback route in Azure Static Web App, you should add routing rules to your app.  
You can do that by adding a file called **`staticwebapp.config.json`** and make that file available in the root of your deployment folder.  
In that file add the following routing rule:  
```json
{
    "navigationFallback": {
      "rewrite": "index.html",
      "exclude": ["/images/*.{png,jpg,gif,ico}", "/*.{css,scss,js}"]
    }
}
```
This will redirect any url to the root `index.html`.  
And make sure when you deploy your solution to add that file in the deployed package.  
Now we know how to fix it on Azure Statis Web App, but if you want to understand what the problem in more details continue reading.  

## What is the problem with SPA routing?

SPA routing is happening on the client side, and not communicating back to the server.  
For example, let consider an e-commerce SPA application on the address `Https://www.my-ecommerce-site.com`.  
And the user navigate on these urls:
```bash
Https://www.my-ecommerce-site.com/shirts
Https://www.my-ecommerce-site.com/computer
Https://www.my-ecommerce-site.com/shopping-carts
```

All these navigations run in the browser and no communication (except for any API REST calls) to the server.  

But the user want to save a link on his favorite to come back later to it, or send the link to a friend.  
The friend open the link: `Https://www.my-ecommerce-site.com/computer` from his browser.  
The problem is the server won't recognize the url: `/computer`.  

## How old SPAs did use client side routing?
Before HTML5 introduce the changes in the [history API](https://developer.mozilla.org/en-US/docs/Web/API/History_API), the old SPA applications used hash **`#`** in their url to split between the server part of the url and client side of url.  
If you developed a SPA 10 years ago, (I remember my first Angular 1 application 10 years ago), then you used that hash technique to fix the problem.  
So when the user navigate to a client side url, the url will be like: 
```html
Https://www.my-ecommerce-site.com/#/computer
```
This type of URL didn't have any issue with the server. 
When the server receive that URL, the server will ignore the part after the hash and resolve only the first part, and then the SPA application will resolve the part after the hash.

## History API and moving away from the hashed URL:

When HTML 5 came up with changes in the browser capabilities, they added capabilities to manipulate the history of the browser and change the url without navigating back to the server without using the hash technique.  
Beside that, the hash in url were not good for SEO.  
So newer SPA frameworks (React, and Angular newer versions) adopted routing that based on normal url.
So we can now use a URL like this: `Https://www.my-ecommerce-site.com/computer`.  

But there was a problem, the server won't recognize the routing url.  
So remember the example of someone share a link with his friend?  
Well, that URL won't be resolvable by the server.  

## How to fix non-hash URL routing on the server: 

To fix the issue on the server, the solution is very easy, which is routing any client un-resolved url from the server to the root index.html of the application, which will serve the whole html/js/css files to the browser, and then the client application will resolve the url.

