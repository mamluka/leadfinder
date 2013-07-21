angular.module('leadFinder.geo.controllers', ['leadFinder.services'])
    .controller('GeoStateController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {

        $rootScope.$on('change-page', function (e, data) {
            $scope.showPage = data.page == "geo";
        });

    }])
    .controller('GeoZipCodeController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', 'apiUrl', function ($scope, $rootScope, wizard, facetEvents, apiUrl) {

        $rootScope.$on('change-page', function (e, data) {
            $scope.showPage = data.page == "geo";
        });

        var savedFacet = wizard.getSavedFacetFor('zip');
        if (savedFacet) {
            $scope.zipList = savedFacet.join('\n');
        }

        $scope.loadFromForm = function () {

            $scope.loadingInProgress = true;

            var data = $scope.zipList;

            var zipLines = data.split('\n');
            var zipCodes = zipLines.join(',');

            wizard.update('zip', zipCodes);

            facetEvents.facetsSelected('Zip codes', zipLines.length + ' Zips', 'geo');
            facetEvents.recalculateTotal();

            $rootScope.$on('facets-recalculate-total-finished', function () {
                $scope.$apply(function () {
                    $scope.loadingInProgress = false;
                });
            });
        };

        $scope.loadingInProgress = false;

        $('.zip-file-uploader').upload({
            name: 'file',
            action: apiUrl + "/upload/zip-list",
            autoSubmit: true,
            onSubmit: function () {
                $scope.$apply(function () {
                    $scope.loadingInProgress = true;
                });


                $('.zip-file-loader-progress').show();
                $('.zip-file-uploader').prop('disabled', true);
            },
            onComplete: function (data) {
                $scope.$apply(function () {
                    $scope.loadingInProgress = false;
                    $scope.zipList = data.join('\n')
                    $scope.loadFromForm();
                });

                $('.zip-file-loader-progress').hide();
                $('.zip-file-uploader').prop('disabled', false);
            }

        });

    }]);