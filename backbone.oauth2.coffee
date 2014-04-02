do ($, Backbone, _) ->

    parseUrl = (url) ->
      a = document.createElement 'a'
      a.href = url
      a

    class Router extends Backbone.Router

      routes:
        'access_token=*access_token': 'login'
        'logout': 'logout'

      login: (access_token) ->
        access_token = @extractToken access_token
        location.hash = ''
        @trigger 'login', access_token

      logout: ->
        @trigger 'logout'

      extractToken: (access_token) ->
        access_token.replace /&.*$/, ''

    class Me extends Backbone.Model

      initialize: ->
        @registerAccessToken()
        @router = new Router
        @listenTo @router, 'checkin', @checkin
        @listenTo @router, 'login', @login
        @listenTo @router, 'logout', @logout

      login: (access_token) ->
        return @logout() unless access_token
        me = this
        @trigger 'login', access_token, (meUrl) ->
          me.url = me.getUrl meUrl, {access_token}
          success = -> me.refresh access_token
          error = -> me.logout()
          me.fetch {success, error}

      logout: ->
        @trigger 'logout', (client_id, base_url) ->
          redirect_uri = "#{document.location.protocol}//#{document.location.host}"
          querystring = $.param {client_id, redirect_uri}
          location.href = "#{base_url}/oauth/logout?#{querystring}"

      refresh: (access_token) ->
        @reload()
        me = this
        @trigger 'refresh', (refresh_url) ->
          $.ajax
            url: me.getUrl refresh_url, {access_token}
            success: (data) -> me.trigger 'login', data.access_token, ->
              me.trigger 'after:refresh', data.access_token

      checkin: ->
        me = this
        hash = Backbone.history.getHash()
        return if flag = /^access_token=/.test(hash) or hash is 'logout'
        @trigger 'checkin', (access_token) -> me.login access_token

      getUrl: (baseUrl = '', param = {}) ->
        baseUrl += if baseUrl.match(/\?/) then "&" else "?"
        baseUrl += $.param param
        baseUrl

      go: (hash) ->
        @router.navigate hash, trigger: true

      reload: ->
        Backbone.history.loadUrl Backbone.history.getHash()

      registerAccessToken: ->
        me = this

        $.ajaxPrefilter (options, originalOptions, jqXHR) ->
          return unless options.access_token
          me.trigger 'checkin', (access_token) -> options.url = me.getUrl options.url, {access_token}

        Backbone.syncAlias = Backbone.sync
        Backbone.sync = (method, model, options) ->
          options.access_token = model.access_token
          Backbone.syncAlias.call(this, method, model, options)


    Backbone.oauth2 = (oauth2) ->

      oauth2 ?=
        baseUrl: 'http://example.com'
        clientId: 1

      meUrl = oauth2.baseUrl + '/account/me'
      refreshUrl = oauth2.baseUrl + '/oauth/refresh_token'

      me = new Me

      me.on 'checkin', (next) ->
        access_token = localStorage.getItem 'access_token'
        next access_token

      me.on 'login', (access_token, next) ->
        localStorage.setItem 'access_token', access_token
        next meUrl

      me.on 'refresh', (next) ->
        next refreshUrl

      me.on 'logout', (next) ->
        localStorage.removeItem 'access_token'
        next oauth2.clientId, oauth2.baseUrl

      me
