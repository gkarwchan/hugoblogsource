---
title: Memoization in Python and JavaScript
date: '2020-09-20T09:45:00'
tags:
- python
- javascript
- performance
---


Memoization is a technique that is used a lot in Dynamic Programming and in general to speed up algorithms.  
Memoization is the same as caching but in functional programming. The Caching mechanism will store the data into a cache store, and that data can be from anywhere (HTTP page, REST call, ... etc) , where memoization is specific to cache the results of a function, and it create and maintain the store inside the function itself (so the function will be pure function) and send the store as a parameter into the function arguments.  

<!--more-->

## Python implementation
Python already comes with a built-in memoization function, but for learning purpose let us try to implement the memoization ourselves.  
As memoization used mainly in functional programming and in function, it is better to implement it as a [Decorator](https://www.datacamp.com/community/tutorials/decorators-python).

We create a decorator and pass to it the calculation function as a parameters.

```python
def memoize(func):
    cache = dict()

    def memoized_func(*args):
        if args not in cache:
          cache[args] = func(*args)
        return cache[args]

    return memoized_func
```

Let us see an example how to use it with the fibonacci calculation:

```python
@memoize
def fibonacci(c):
  if c in [0, 1]: return c
  return fibonacci(c - 1) + fibonacci(c - 2)
```

But, we don't need to implement memoization ourselves, because Python comes with a built-in function to do that.  
[**`functools.lru_cache`**](https://docs.python.org/3/library/functools.html#functools.lru_cache) is a decorator function that does that.  

```python
from functools import lru_cache

@lru_cache
def fibonacci(c):
  if c in [0, 1]: return c
  return fibonacci(c - 1) + fibonacci(c - 2)
```

## JavaScript implementation

Again in JavaScript as in Python before we use the idea of higher-order function to build the memoization:  

```js
function memoization(func) {
    var cache = {};
    return function(){
      var key = JSON.stringify(arguments);
      const args = Array.prototype.slice.call(arguments);
      if (!(key in cache)){
        val = func.apply(null, vv);
        cache[key] = val;
      }
      return cache[key]
    }
}
```

The code above is ceating a higher order function that takes a function as an argument.  
In order to make it general we should create a cache that match all arguments as one key. The way to do that is to convert the arguments to a unique string. The way to do that is to convert using `JSON.stringify`.  
The second step is to capture all arguments as an array to pass them to calling the function later.  

Let's use the function as follows:  

```js
function fibonacci(c) {
  if (c < 2) return c;
  return fibonacci(c -1 ) + fibonacci(c - 2)
}

fibonacci = memoization(fibonacci);

const val = fibonacci(46);
```

