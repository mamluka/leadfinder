'use strict';

angular.module('leadFinder', ['leadFinder.services', 'leadFinder.directives', 'leadFinder.controllers', '$strap.directives'],function ($routeProvider, $locationProvider) {

    $routeProvider.when('/geographics/states', {
        templateUrl: '/partials/geographics-states.html',
        controller: 'GeoStateController'
    });

    $routeProvider.when('/geographics/zip', {
        templateUrl: '/partials/geographics-zip.html',
        controller: 'GeoZipCodeController'
    });

    $routeProvider.when('/demographics', {
        templateUrl: '/partials/demographics.html',
        controller: 'DemographicsController'
    });

    $routeProvider.when('/economics', {
        templateUrl: '/partials/economics.html',
        controller: 'EconomicsController'
    });

    $routeProvider.when('/mortgage', {
        templateUrl: '/partials/mortgage.html',
        controller: 'MortgageController'
    });

    $routeProvider.when('/lifestyle', {
        templateUrl: '/partials/lifestyle.html',
        controller: 'LifestyleController'
    });

    $routeProvider.when('/order-form', {
        templateUrl: '/partials/order-form.html',
        controller: 'OrderFormController'
    });

    $routeProvider.when('/order-form/order-ready', {
        templateUrl: '/partials/order-ready.html',
        controller: 'OrderReadyController'
    });

    $routeProvider.otherwise({redirectTo: '/geographics/states'});


}).run(['Analytics', 'DefaultSearchConfigurations', '$rootScope', 'domain', '$location', function (analytics, defaults, $rootScope, domain, $location) {

        $rootScope.$on('$routeChangeSuccess', function () {
            var path = $location.path();
            analytics.reportNavigation(path)

            mixpanel.track(
                'Page changed',
                { page: path }
            );
        });

        defaults.apply();

        document.domain = domain;


    }]);
