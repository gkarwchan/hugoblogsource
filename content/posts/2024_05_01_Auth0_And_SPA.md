+++
title = "Auth0 and SPA"
date = 2024-05-01T10:41:54-06:00
short = true
toc = true
draft = true
tags = ["security"]
categories = []
series = []
comment = true
+++

Auth0 streamlines lots of complexity for you when it comes to authenticate your SPA application.  
In this article we will talk about the features and details of that functionality.

## Silent authentication

`OpenId Connect` protocol supports a `prompt=none` parameter on the authentication request, which indicate the Authentication Server (`AS`) must not display any user interaction. The Auth0 server will either return a successful token or return an error, in which case the user has to redirect to login.  
In `Authorization Code Flow with PKCE` in conjuction with Silent Authentication can renew your session without relogin.  

#### Silent authentication API endpoint
to authenticate using OpenId Connect use the following endpoint:  

```http
GET https://{yourDomain}/authorize
    ?response_type=id_token token&
    client_id=...&
    redirect_uri=...&
    state=...&
    scope=openid...&
    nonce=...&
    audience=...&
    response_mode=...&
    prompt=none
```

#### How silent authentication work?

Auth0 used to use cookies to store the Auth0 session to be able to get back the authentication.  
But modern browsers prevent third-party cookies, therefore Auth0 shifted to use : **`Refresh Token Rotation`**, which provides a secure way for using refresh tokens in SPA while providing end-users with seamless access to resources without the disruption in UX.  

https://auth0.com/docs/authenticate/login/configure-silent-authentication

The possible values for ERROR_CODE are defined by the OpenID Connect specification:

Response	Description
login_required	The user was not logged in at Auth0, so silent authentication is not possible. This error can occur based on the way the tenant-level Log In Session Management settings are configured; specifically, it can occur after the time period set in the Require log in after setting. See Configure Session Lifetime Settings for details.
consent_required	The user was logged in at Auth0, but needs to give consent to authorize the application.
interaction_required	The user was logged in at Auth0 and has authorized the application, but needs to be redirected elsewhere before authentication can be completed; for example, when using a redirect rule.


https://auth0.com/docs/secure/tokens/token-best-practices