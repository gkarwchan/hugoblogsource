+++
title = "OAuth, OpenID Connect, SSO and Authentication Flows in plain English."
date = 2023-10-27T12:41:54-06:00
short = true
toc = true
tags = ["security"]
categories = []
series = []
comment = true
+++

Gone are the days when you force your users to register into your application by creating username/password.
Everyone wants to skip that process when they can identify themselves using other ways (google, facebook, twitter…), and they want to use their single sign on process to identify them across multiple applications and multiple websites.
In this post I am trying to explain the process and its technologies in simple English.

## An explanation by example:
So you are a developer who is building an application and want to allow your users to use their Google credentials to authenticate themselves into your account.
I am going to explain to you the concepts and the technologies.  

To accomplish that, your application must make a request to some API service on the Google Account website in order to initiate the user authentication process and receive a response that identifies the user.
The Google Account website is the only place where the authentication process should run, and where the user enter their credentials. And Google authentication service should ensures that the credentials are safe and hidden from our application.  

The process of using an external server to sign-on and using its returning identity in different applications is called **`Single Sign-On (SSO)`**.  

Google Account website stores information about the user who did previously register into Google Account website. The digital information that uniquely identifies a user on Google Account website and shared on other websites and domains is known as **`Federated Identity`**.  
The Google Account website has to provide API services that will achieve that process, and these services must use common protocols and policies that are understood by our application and Google Account. These protocols and policies are called **`Federated Identity Management (FIdM)`**. 

Google Account is the provider that provides Authentication service to identify users, and return their Federated Identities, and the technical terms for it is: **`Federated Identity Provider`**.  

Our application will be the consumer or the client for **`FIdM`**.
There are many different Federated Identity Providers: Google, Microsoft, Twitter, Facebook…etc. They all provide these FIdM services for industry standard protocols.

## What technologies and protocols are used?

There are three technologies that provide FIdM services:
1. **SAML** (Security Assertion Markup Language):  It is the oldest technology, and although it is limited used now but still kicking around.
2. **OAuth 2.0**: the most common one, because it is implemented by all providers.
3. **OpenID Connect**: is it built on top of OAuth but it cut lots of extra stuff and concentrate on authentication. 


### How they are different?

#### SAML:
SAML was the oldest one, and is used mainly for web applications and mostly internal web applications. It uses XML to communicate to the Identity providers. SAML only returns a digital identity called **`SAML Assertion`** to identify the user. The `SAML Assertion` is very simple and it is the simplest representation of the user.

#### OAuth 2.0:
Although OAuth is used as one of FIdM technologies, but it was mainly built for that purpose.
With the rising of social media and the wealth of its data, social media companies wanted to provide its data and share user data across the applications.
They provided more sophisticated protocols to share user information and allow users to choose what information they want to share with other apps, and this is how OAuth 2.0 was built.
OAuth 2.0 has all features of FIdM, plus it add more to allow users to share more info about themselves to other apps and the users can choose what they want to share.  
For example on google we all saw this when using google login.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ngm47aure1o2jr0ta3ac.png)

As you see that OAuth has more that SSO and FIdM, but it built very good technologies and protocols, and this is why OpenID came up to life.

#### OpenID Connect:

Because OAuth had good technologies and standards to achieve SSO and FIdM, but has way more of Authorization and sharing information, the industry built a new standard that use OAuth technologies but concentrate only on the Authentication process and cut out the authorization, and it only share the basic data that uniquely identify the user. This new standard is OpenID Connect 1.0.
OpenID Connect uses lots of common technologies with OAuth, that is sometimes it get confused.

## How the process works?

OAuth created many workflows each work better for a specific type of applications. OAuth called these workflows: **`Flows`** 
OpenID still using these flows but slightly modified them. So understand them with OAuth is the same as OpenID.
We can define these types of applications:

1. Website application that serve its own UI.
2. Single Page Application (SPA), where the client is a thick JavaScript application that can be hosted on any place, and it called different API application.
3. Mobile native APP.
4. Local desktop App.
Each type has its matching OAuth 

| Application Type | OAuth Flow |
| ----- | ----- |
| Web application | Authorization Flow |
| SPA | the Authorization Code Flow with Proof Key for Code Exchange (PKCE) <br> Implicit Flow used to be the one but not any more |
| Local Desktop App | Client Credential Flow |
| Native mobile APP | the Authorization Code Flow with Proof Key for Code Exchange (PKCE) |

## Conclusion
Hopefully I was able to explain these technical terms and technologies in simple plain English.
