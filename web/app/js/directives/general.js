angular.module('leadFinder.general.directives', ['leadFinder.services'])
    .directive('loadingOverlay', ['$rootScope', function ($rootScope) {
        return {
            controller: function ($scope, $element) {
                $rootScope.$on('remove-loading-overlay', function () {
                    $($element).remove();
                });
            }
        };
    }]);