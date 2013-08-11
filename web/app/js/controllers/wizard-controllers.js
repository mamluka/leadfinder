angular.module('leadFinder.wizard.controllers', ['leadFinder.general.services'])
    .controller('DemographicsController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {

    }])
    .controller('MortgageController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {

    }])
    .controller('EconomicsController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {

    }])
    .controller('LifestyleController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {
        $rootScope.$broadcast('remove-loading-overlay');
    }])
    .controller('ContactUsController', ['$scope', '$rootScope', '$http', 'apiUrl', function ($scope, $rootScope, $http, apiUrl) {

        $rootScope.$broadcast('remove-loading-overlay');

        $scope.isBuyButtonDisabled = function () {
            return $scope.contactForm.$invalid;
        };

        $scope.send = function () {
            $http.post(apiUrl + '/contact-us/send', {
                message: $scope.message,
                email: $scope.email

            }).success(function (data) {
                    alert('Thank you for contacting us');
                    window.location.href = "/";
                })
                .error(function (data) {
                    alert('Error sending contact form');
                });
        }
    }]);