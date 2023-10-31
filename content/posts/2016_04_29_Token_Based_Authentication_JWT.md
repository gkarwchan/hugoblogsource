+++
title = "Token Based Authentication and JWT."
date = 2016-04-29T12:41:54-06:00
short = true
toc = true
tags = ["security"]
categories = []
series = []
comment = true
+++

HTTP protocol specified only two standard authentication mechanisms, which are implemented in every browser, the [HTTP basic authentication]({% post_url 2016-03-31-web-security-basic-authentication %}), and the Digest authentication which is obsolete now because it is not secure anymore.  
Because they are limited and work only on user name/password idea, the development communities in every web development platform came up with their better customized solutions.  
JWT is one of the most promising and smart authentication ideas that is taking famous recently.<!--more-->

<br />

## Token is the main idea ## 
There is one common basic pattern among all security technologies across all programming platforms, which is authenticate the user only once and issuing a "__*ticket*__" or a "__*token*__", and the browser will use that ticket for every subsequent call.  
The token/ticket will have an expiry date and time, and will be invalid after that time.  

<br />  
 

#### How the web browser send the token: ####
One of the early idea developed was using the cookies to save the token, but a better solution emerged, which is sending the token in the header of every request, which proved to be a better solution in many different ways. The phrase "Token Based Authentication" is mostly used in the industry to describe the later solution, even the cookie based solution, is a ticket-based solution as well.  
Let us see an example of both solutions:  

<br />

#### Cookies Based Authentication:  ####
This solution was used for a long time, and the most famous implementation for it was ASP.NET Forms Authentication, and Wordpress.  
The server after authenticate the user, will respond with a response that has a __Set-Cookie__ header attribute in the response header, which looks like this:
<pre><code class="language-http">HTTP/1.0 200 OK
Content-type: text/html
Set-Cookie: theme=light
Set-Cookie: sessionToken=abc123; Expires=Wed, 09 Jun 2021 10:18:14 GMT</code></pre>
The browser (assuming they allow cookies), will keep the cookie until it is expired, and will submit it on every subsequent request to that web site as follows:   
<pre><code class="language-http">GET /spec.html HTTP/1.1
Host: www.example.org
Cookie: theme=light; sessionToken=abc123</code></pre>

Earlier implementations for this approach were using sessions and saving the sessions and sending the session ID as the "ticket", but because sessions are not easy to scale, the session stopped being used long time ago.  
Cookies had many issues (that we are going to cover in next section), which pushed the industry to find better solutions, which brought the idea of token based authentication. 

<br />

#### Token Based Authentication:  ####
Using the same approach of generating an access token when authenticating, but instead of sending the token in a cookie, it use an HTTP header attribute (usually Authorization HTTP header) to send the token.  
This solution was developed mainly by OAuth authentication, but it doesn't have to be used only in OAuth, and it can be used by local security based solution.  
The solution became mature with development of more robust standard like [Jason Web Token (JWT)](https://jwt.io/), which became the de facto standard for modern web security.  
There are two common approach to send this access token:  

1. __Bearer token__: Bearer token is an non encrypted token. If you want to use it, you should use it over HTTPS. 
This is how a call with the bearer token will look like:
    <pre><code class="language-http">GET /resource/1 HTTP/1.1
       Host: example.com
       Authorization: Bearer mF_9.B5f-4.1JqM</code></pre>
2. __MAC token__: MAC token is an encrypted token, and it is more complex than the bearer. 
    <pre><code class="language-http">GET /resource/1 HTTP/1.1
         Host: example.com
         Authorization: MAC id="h480djs93hd8",
        nonce="274312:dj83hs9s",
        mac="kDZvddkndxvhGRXZhvuDjEWhGeE="</code></pre>
        
<br />

## Advantages of Token Based Authentication ##
The are many advantages of token based authentication over cookies:  

1. Cookies could be disabled by the user:
In that case you have to force your users to use cookies in order for them to use your application.  
2. They won't work across-domains:  
So you cannot use the same credentials with many different domains, where in token based, you can authenticate in one place, and use the same token across many different domains.  
3. Cookies and mobiles are not friends together.
4. Cookies are volunerables for [CSRF attacks](https://en.wikipedia.org/wiki/Cross-site_request_forgery).

<br /> 

## JSON Web Tokens (JWT) ##
JWT became lately the most common used authentication solution for APIs and mobile solutions.  
JWT is a claim based authentication. When a user authenticate itself only at the beginning, the application checks what this user have access to, and what the user will claim, and issues a token that will have all these claims, and then signed with a hash algorithm, and send it back to the client.  
The client will store the token either with a cookie, or with an HTML5 local data store, and upon each request the client will submit this data in the header of the request as a bearer token or a MAC token. JWT as the token based authentication is not supported by the browsers, and requires some kind of JavaScript libraries to support it. 