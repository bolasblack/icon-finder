'use strict'

### Controllers ###

angular.module('app.controllers', [
  'ngCookies'
  'ui.bootstrap'
])

.controller('SearchCtrl', [
  '$scope', '$state'
  ($scope ,  $state) ->
    $scope.$watch (-> $state.params?.term), (term) ->
      $scope.searchTerm = term

    $scope.search = ->
      $state.go 'home', term: $scope.searchTerm

])

.controller('AppListCtrl', [
  '$scope', '$stateParams', 'App'
  ($scope ,  $stateParams ,  App) ->
    removeEmptyKey = (obj) ->
      newObj = {}
      _(obj).forEach (value, key) ->
        newObj[key] = value if value?
      newObj

    params = removeEmptyKey $stateParams
    if params.term
      $scope.apps = App.query params

    $scope.isLanding = not $stateParams.term

    $scope.isResultEmpty = ->
      $scope.apps?.$resolved and not $scope.apps?.length and not $scope.isLanding

])

