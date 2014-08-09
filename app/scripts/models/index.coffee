'use strict'

### Models ###

angular.module('app.models', [
  'ngResource'
])

.factory('App', [
  '$resource'
  ($resource) ->
    App = $resource(
      'https://itunes.apple.com/search?callback=JSON_CALLBACK'
      null
      query:
        method: 'jsonp'
        isArray: true
        params:
          media: 'software'
          limit: 200
        transformResponse: (datastr, headersGetter) ->
          data = angular.fromJson datastr
          data.results
    )

    App
])

