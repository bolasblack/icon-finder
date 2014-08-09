'use strict'

# Declare app level module which depends on filters, and services
angular.module('app', [
  'ui.router'

  'app.controllers'
  'app.directives'
  'app.services'
  'app.filters'
  'app.models'
])

.config([
  '$locationProvider'
  '$stateProvider'
  '$urlRouterProvider'

($locationProvider, $stateProvider, $urlRouterProvider) ->
  $locationProvider.html5Mode(false).hashPrefix("!")

  $urlRouterProvider.otherwise '/'

  $stateProvider
    .state('home',
      url: '/:term?country&media&entity&attribute&lang&version&explicit&limit'
      templateUrl: 'partials/home.html'
      controller: 'AppListCtrl'
    )
])

angular.element(document).ready ->
  angular.bootstrap(document, ['app'])

