'use strict'

### Directives ###

angular.module('app.directives', [])

.directive('spin', [
  '$q'
  ($q) ->
    link: (scope, $elem, attrs) ->
      spinner = new Spinner().spin()

      scope.$watch attrs.spin, (promise) ->
        $elem.append spinner.el
        $q.when(promise).then spinner.stop.bind(spinner)

])

