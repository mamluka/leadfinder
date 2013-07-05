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

    $routeProvider.otherwise({redirectTo: '/geographics'});


}).run(['Analytics', 'DefaultSearchConfigurations', '$rootScope', function (analytics, defaults, $rootScope) {

        $rootScope.$on('change-page', function (e, data) {
            analytics.reportNavigation(data.page)
        });

        defaults.apply();

        document.domain ='leadfinder';

        $.unblockUI();

    }]);
