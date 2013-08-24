angular.module('leadFinder',
    ['leadFinder.values.services',
        'leadFinder.general.services',
        'leadFinder.general.directives',
        'leadFinder.wizard.directives',
        'leadFinder.order-form.directives',
        'leadFinder.analytics.directives',
        'leadFinder.geo.controllers',
        'leadFinder.login.controller',
        'leadFinder.wizard.controllers',
        'leadFinder.summery.controller',
        'leadFinder.order-form.controllers',
        '$strap.directives'],
    function ($routeProvider, $locationProvider) {

        $routeProvider.when('/geographics/states', {
            templateUrl: '/partials/geographics-states.html',
            controller: 'GeoStateController',
            page: 'geographics'

        });

        $routeProvider.when('/geographics/zip', {
            templateUrl: '/partials/geographics-zip.html',
            controller: 'GeoZipCodeController',
            page: 'geographics'
        });


        $routeProvider.when('/demographics', {
            templateUrl: '/partials/demographics.html',
            controller: 'DemographicsController',
            page: 'demographics'
        });

        $routeProvider.when('/economics', {
            templateUrl: '/partials/economics.html',
            controller: 'EconomicsController',
            page: 'economics'
        });

        $routeProvider.when('/mortgage', {
            templateUrl: '/partials/mortgage.html',
            controller: 'MortgageController',
            page: 'mortgage'
        });

        $routeProvider.when('/lifestyle', {
            templateUrl: '/partials/lifestyle.html',
            controller: 'LifestyleController',
            page: 'lifestyle'
        });

        $routeProvider.when('/order-form', {
            templateUrl: '/partials/order-form.html',
            controller: 'OrderFormController',
            page: 'order-form'
        });

        $routeProvider.when('/order-form/order-ready', {
            templateUrl: '/partials/order-ready.html',
            controller: 'OrderReadyController',
            page: 'order-form'
        });

        $routeProvider.when('/paypal-payment-successful', {
            templateUrl: '/partials/paypal-payment-successful.html',
            controller: 'PaypalSuccessfulController',
            page: 'order-form'
        });

        $routeProvider.when('/paypal-payment-failed', {
            templateUrl: '/partials/paypal-payment-failed.html',
            controller: 'PaypalFailedController',
            page: 'order-form'
        });

        $routeProvider.when('/contact-us', {
            templateUrl: '/partials/contact-us.html',
            controller: 'ContactUsController',
            page: 'contact-us'
        });

        $routeProvider.otherwise({redirectTo: '/geographics/states'});


    }).run(['Analytics', 'DefaultSearchConfigurations', '$rootScope', 'domain', '$location', 'IdGenerator', 'Authentication', function (analytics, defaults, $rootScope, domain, $location, idGenerator, authentication) {

        window.mixpanel = window.mixpanel || { track: function () {
        }, identify: function () {
        }, people: { set: function () {
        } } };
        window.ga = window.ga || function () {
        };

        $rootScope.$on('$routeChangeSuccess', function (angularEvent, currentRoute) {
            var path = $location.path();
            analytics.reportNavigation(path)

            _.each($('.top-nav li'), function (n) {
                var link = $(n);

                if (link.data('top-page') == currentRoute.page)
                    link.addClass('active');
                else
                    link.removeClass('active');

            });

            $('nav_' + currentRoute.topPage).addClass('active');

            mixpanel.track(
                'Page changed',
                { page: path }
            );
        });

        defaults.apply();

        document.domain = domain;

        mixpanel.identify(new Date().getTime().toString());
        mixpanel.people.set({
            loggedIn: false
        });

        $rootScope.userId = idGenerator.generate();

        authentication.getUser()
            .success(function (user) {
                $rootScope.$broadcast('user-status-retrieved', user)
            });

    }]);
