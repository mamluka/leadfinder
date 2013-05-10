'use strict';

/* Controllers */

angular.module('leadFinder.controllers', ['leadFinder.services']).
    controller('WizardController', ['$scope', '$rootScope', function ($scope, $rootScope) {
        $scope.displayTabs = false;

        $rootScope.$on('display-tabs', function () {
            $scope.displayTabs = true;
        });

    }])
    .controller('GeographicsController', ['$scope', '$rootScope', function ($scope, $rootScope) {

        $scope.displayGeo = true;

        $scope.next = function () {
            $scope.displayGeo = false;
            $rootScope.$broadcast('display-tabs');
        }

    }])
    .controller('SummeryController', ['$scope', 'Wizard', 'Leads', function ($scope, wizard, leads) {

        $scope.selectedFacetsIndicators = [];

        $scope.$on('facets-recalculate-total', function () {

            var selectedFacets = wizard.getSelectedFacets()
            leads.getTotalLeadsByFacets(selectedFacets).done(function (data) {
                $scope.$apply(function () {
                    $scope.total = data.total;
                })
            })
        })

        $scope.$on('facets-selected', function (e, data) {

            if (data.value == "none") {
                $scope.selectedFacetsIndicators = _.reject($scope.selectedFacetsIndicators, function (x) {
                    return x.label == data.label;
                });
                return;
            }

            var alreadyUsed = _.some($scope.selectedFacetsIndicators, function (x) {
                return x.label == data.label
            });

            if (alreadyUsed) {
                $scope.selectedFacetsIndicators = _.map($scope.selectedFacetsIndicators, function (x) {
                    if (x.label == data.label) {
                        x.value = data.value;
                        return x;
                    }
                    return x;
                })
            }
            else {
                $scope.selectedFacetsIndicators.push({label: data.label, value: data.value});
            }
        })

        $scope.download = function () {
            wizard.download()
        }
    }])
;