---
layout: post
title: 'Regular expression: Extract HTML Links'
date: '2020-09-11T09:45:00'
author: Ghassan Karwchan
tags:
- algorithm
---


Explain advanced concepts of Regular Expressions through practical recipes:  
In this recipe we are going to cover:

* Negated Character class
* Non-capturing group
* Non-Greedy quantifier.
* Python's `findall`, and JavaScript's `exec`

<!--more-->


## Problem Description

We need to extract the html links, or the anchor tags in an html element. We want to extract the url link and the text description for that link.  

The input will be an HTML document, The output we need has the following format:  

```code
url, Text description
```
For example

```html
<div class="portal" role="navigation" id='p-navigation'>
<h3>Navigation</h3>
<div class="body">
<ul>
 <li id="n-mainpage-description"><a href="/wiki/Main_Page"
  title="Visit the main page [z]" accesskey="z">Main page</a></li>
 <li id="n-contents"><a href="/wiki/Portal:Contents" 
 title="Guides to browsing Wikipedia">Contents</a></li>
 <li id="n-featuredcontent"><a href="/wiki/Portal:Featured_content" 
 title="Featured content  the best of Wikipedia">Featured content</a></li>
<li id="n-currentevents"><a href="/wiki/Portal:Current_events"
 title="Find background information on current events">Current events</a></li>
<li id="n-randompage"><a href="/wiki/Special:Random"
 title="Load a random article [x]" accesskey="x">Random article</a></li>
<li id="n-sitesupport"><a href="//donate.wikimedia.org/wiki/Special:
FundraiserRedirector?utm_source=donate&utm_medium=sidebar&utm_campaign=
C13_en.wikipedia.org&uselang=en" title="Support us">Donate to Wikipedia</a></li>
</ul>
</div>
</div>    
```
Will have the follwoing output:


```JavaScript
/wiki/Main_Page,Main page
/wiki/Portal:Contents,Contents
/wiki/Portal:Featured_content,Featured content
/wiki/Portal:Current_events,Current events
/wiki/Special:Random,Random article
//donate.wikimedia.org/wiki/Special:FundraiserRedirector?utm_source=\
donate&utm_medium=sidebar&utm_campaign=C13_en.wikipedia.org&uselang=en,Donate to Wikipedia    
```


## Code

The final code in Python:

```python
import re
def extract_links(lines):
    pat = r'<a\s+(?:[^>]*?\s*)?href="([^>"]*)"\s*[^>]*>\s*(?:<[^>]*>)?([^>]*)</'
    r = re.compile(pat, re.M)
    return [','.join(j) for j in r.findall(lines)]
    
```

<br />
<br />

## Code Description

Let us explain the code.  
  
For Python:  

1. The HTML tag for link are the Anchor &lt;a>, and end with />, so the pattern will be something like this &lt;a - - -
    ```python
    r'<a - - -'
    ```
2. between the `a` tag and next html attributes there is one space at least..
    ```python
    r'<a\s+'
    ```
3. The link tag contains many attributes, and we care only about the attribute **`href`**. so we need to select the attriute `href` as follows:
    ```python
    r'<a\s+href="'
    ```
4. the href has the following format: 
    ```html
    <a firstAttribute="somedata"
    href="/somelink/somefile.html" 
    secondAttribute="someattr">Some Text here</a>
    ```
    So to capture that

    ```python
    r'<a\s+href="'
    ```
5. We need to capture the data in that attribute so we open a capturing group. The capturing group will end with the end of the attribute. As the atrribute will end with double quotes `"` so we can capture any character except `>` and `"`. We can acheive that using **`Negated Character Class`** which can be achieved using `[^]`. The following statement capture all the text inside the `href` attribute. Notice as well how we ended up the attribute with the closing double quote.
    ```python
    r'<a\s+href="([^>"]*)"'
    ```
6. The link tag contains other attributes that we are not interested in, so we can get them out by using **`non capturing group`**. They can show up before or after the `href` attributes.  
The attributes separated by spaces, so we can write a blue-print of the pattern as follows:
    ```python
    (?:[here we put the pattern to capture]\s*)?
    ```

7. the pattern to match the other attributes is any character that doesn't match the end of the html tag **`>`**, and we use negated character class again as follows: **`[^>]`**. But using only that we will end up using all data in the anchor (link) tag, so we use non-greedy character as follow:  
    ```python
    r'<a\s+(?:[^>]*?\s*)href="([^>"]*)"'
    ```
8. The previous match the attributes before `href`. To add the attributes after the `href` we add as well:
    ```python
    r'<a\s+(?:[^>]*?\s*)?href="([^>"]*)"\s*[^>]*'
    ```

9. the link tag will end with **`>`**
    ```python
    r'<a\s+(?:[^>]*?\s*)?href="([^>"]*)"\s*[^<]*>'
    ```

10. the next part is to capture the text description of the link. We capture the text, which can include anything except end of tag **`<\a>`**.
    ```python
    r'<a\s+(?:[^>]*?\s*)?href="([^>"]*)"\s*[^<]*>([^<]*)'
    ```
11. And we end up with the link end tag **`<\a>`**.
    ```python
    r'<a\s+(?:[^>]*?\s*)?href="([^>"]*)"\s*[^<]*>([^<]*)</'
    ```
  
12. BUT WAIT. We are not done yet. there is more small issue.  
    Sometimes the link tag contains nested tags as follows:
    ```html
    <a href="/somelink/somefile.html" ...>
      <img>...</img> <data></data>Some Text here</a>
    ```
    In order to handle this we use non-capturing group for the following pattern:

    ```python
    (?:<[^>]*>)?
    ```
So at the end the final pattern will be as follows:

```python
pat = r'<a\s+(?:[^>]*?\s*)?href="([^>"]*)"\s*[^>]*>\s*(?:<[^>]*>)?([^<]*)</'
```

## Python implementation

We use the method **`findall`** with the MultiLine flag. `findall` will give an iterator of all capturing groups, where each item is a tuplet of the matching capture groups.

```python
import re
r = re.compile(pat,re.M)
htmlInput = '<html> ... the html string </html>'
for j in r.findall(htmlInput):
  # j[0] is the url match
  # j[1] is the text description
```
For more about `findall` check [my previous recipe]({% post_url 2020-05-08-Regular-expression-extract-domain-names %}) where I explained in more details.



<br />
<br />

## Regular Expression Series:

This article is part of a series about regular expression. These are the other articles:  

1. [Advanced Regular Expression By Example : An Introduction]({{< ref "/posts/2020_05_06_Advanced_regular_expression_by_examples" >}})
1. [Extract Comments from code]({{< ref "/posts/2020_05_07_Regular_expression_extract_comments_from_code" >}})
3. [Extract Domain Name]({{< ref "/posts/2020_05_08_Regular_expression_extract_domain_names" >}})
4. Extract Links From HTML Document (this article)