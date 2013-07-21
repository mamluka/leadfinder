angular.module('leadFinder.wizard.controllers', ['leadFinder.services'])
    .controller('DemographicsController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {

    }])
    .controller('MortgageController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {

    }])
    .controller('EconomicsController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {

    }])
    .controller('LifestyleController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {
        $rootScope.$broadcast('remove-loading-overlay');
    }]);