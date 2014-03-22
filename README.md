backbone.oauth2
===============

enhanced backbone with oAuth2

Installation
--------------

```javascript
    bower install --save backbone.oauth2
```

Usage
-----

```javascript
config =
  baseUrl: 'http://api.e-research-solutions.com'
  clientId: 1

# make sure baseUrl + '/account/me' and baseUrl + '/oauth/refresh_token' working
# user localStorage as store engine

me = Backbone.oauth2 config

class Test extends Backbone.Model

  # add access_token: true shall automaticall add access_token to url when fech
  access_token: true

  url: -> 'http://example.com'

class TestCollection extends Backbone.Collection

  # add access_token: true shall automaticall add access_token to url when fech
  access_token: true

  url: -> 'http://example.com'

# passing access_token: true shall automaticall add access_token to url when fech
$.ajax
  access_token: true
  url: 'http://example.com'

# me is a model, listen to it, do something after logged in
me.on 'sync', ->

  # shorthand method for change hash
  me.go '#import'

# try to login
me.checkin()

# start history
Backbone.history.start()
```


License
----

MIT


**Free Software, Hell Yeah!**
