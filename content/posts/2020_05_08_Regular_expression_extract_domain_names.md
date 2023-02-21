---
layout: post
title: 'Regular expression: Extract Domain Names'
date: '2020-05-08T09:45:00'
author: Ghassan Karwchan
tags:
- algorithm
series:
- "regular expression recipes"
---


Explain advanced concepts of Regular Expressions through practical recipes:  
In this recipe we are going to cover:

* Anchors
* Non-capturing group
* Python's `findall`, and JavaScript's `exec`

<!--more-->

## Problem Description

HTML Scraping or Web Scraping is widely used, and we need to build a scrapper to extract the URLs in a web page, and to extract the domain names in those URL.  

An example of the data input

```html
<div class="reflist" style="list-style-type: decimal;">
<ol class="references">
<li id="cite_note-1"><span class="mw-cite-backlink"><b> 
["Train (noun)"](http://www.askoxford.com/concise_oed/train?view=uk). 
<i>(definition – Compact OED)</i>. Oxford University Press
<span class="reference-accessdate">. 
.....
</ol>
</div>
```
The output we need is

```JavaScript
askoxford.com;bnsf.com;hydrogencarsnow.com;mrvc.indianrail.gov.in;web.archive.org
```

The url have variant formats, and the domain name can have different formats. Examples of Url in the text as follow:

```code
http://www.domain.com
https://ww2.anotherdomain.com
https://mydomain.com
```


## Code

The final code in JavaScript:

```javascript
function domainExtract(inputLines){
  let exp = /\bhttps?://(?:www\.|ww2\.)?((?:[\w-]+\.){1,}\w+)\b/g
  const entries = inputLines.map(x => {
      let rslt
      let d = []
      while ((rslt = exp.exec(x)) !== null)
        d.push(rslt[1])
      return d
  }).filter(x => x).reduce((a, b) => a.concat(b), [])
  return Array.from(new Set(entries)).sort().join(';')
}
```

And Python

```python
import re
def extract_domains(lines):
    exp = r'\bhttps?://(?:www\.|ww2\.)?((?:[\w-]+\.){1,}\w+)\b'
    r = re.compile(exp, re.M)
    domains = ';'.join(sorted(set([ f for s in lines for f in r.findall(s) ])))
    return domains
    
```

## Code Description

Let us explain the code.  
  
For Python:  


1. we start by writing the pattern in a string and prefix it with **`r`** prefix, which treat the rest as `Raw` string, which means ignore the escape character **`\`** and treat it as normal character.
    ```python
    r'the pattern string'
    ```
2. The Url code appears anywhere in the string, and we can match it anywhere in the string, and to do that we use special characters called `Anchors` and specifically we use the **`word boundary anchor`**: `\b`.
    ```python
    r'\b patter to match \b'
    ```
3. Then we specify the url schema part (http:// or https://), where (s) is optional.
    ```python
    r'\bhttps?://\b'
    ```
4. Then we need to ignore the **(www or ww2)** part, so we use **`Non-capturing group`** using `(?:)`
    ```python
    r'\bhttps?://(?:www\.|ww2\.)?\b'
    ```
5. and then we need to capture the rest of the text, because the rest contains the domain name, so we add capturing group.  
    ```python
    r'\bhttps?://(?:www\.|ww2\.)?( pattern for domain )\b'
    ```
6. The pattern for domain contains many words with alphanumeric characters, and can have dashes (-), and those words separated by dots (.)
    ```javascript
    // format of domain
    word.second-word.third-word.com
    ```
7. we use the **`Shorthand Character Class`**: `\w`, which matches alphanumeric characters plus underscore, and we add the dash in a character class `[\w-]`.  
    ```python
    r'\bhttps?://(?:www\.|ww2\.)?((?:[\w-]+\.){1,}\w+)\b'
    ```
8. notice that we had to add the word with the dot in a group, and because we don't need to capture that nested group, we used `Non capturing group`.

## A word about Python and JavaScript implementation

We are going to cover more on Python and JavaScript implementation, but for now we are going to talk about Python's findall, and JavaScript's exec.  

#### Python's findall

The Python has many ways to search for a match, including the methods: __*search*__ and __*match*__. But both works on one match at the time.  
*__findall__* will return a list with all non-overlapping occurrences of a pattern.  
The following example:

```python
pattern = re.compile (r'\w+')
pattern.findall('Hello World')
  # output: ['Hello', 'World']
```

If you have more than a capturing group in the pattern, then it will return a list of tuples.

```python
pattern = re.compile(r'(\w+) (\w+)')
pattern.findall('Hello World!, Hello Tom!')
  # output: [('Hello', 'World'), ('Hello', 'Tom')]
```

Another alternative: *__finditer__* which returns an iterator in which each element is a *__MatchObject__*, which gives more information about each match.

```python
pattern = re.compile(r'(\w+) (\w+)')
it = pattern.finditer('Hello World!, Hello Tom!')
match = it.next()
match.groups()
  # output: ('Hello', 'World')
match.span()
  # output: (0, 11)
```

#### JavaScript

JavaScript is a little bit tricky, and arguably it might be the worst implementation among many languages.  
JavaScript didn't have an equivalent for Python's findall until very recently. It is the method `String.matchAll`, and it is supported in Node 12, and very latest browsers.  
If you need to work in Node before 12, or a little bit older browsers, then you have one option to iterate through many matches.  
JavaScript is funky because it implement the first match in different ways, but to match all matches, it force you in one awkward way (before String.matchAll).  
To get all matches with their capturing group, you have to use *__exec__* method of regular expression object and iterate through it.  
An example will be like this: 

```javascript
const exp = /\b(\w)\w+ ?/
 while ((rslt = exp.exec(inputString)) !== null)
    // the capturing group above will be accessed in rslt[1]
    do_something_with_capturing_group_value(rslt[1])
```

## List of posts ##
We are going to explain advanced terms of Regular Expressions through different examples, and through series of posts. To see all articles in this series check here:  

[Check all articles in this list]({{< ref "/series/regular-expression-recipes">}}).  
