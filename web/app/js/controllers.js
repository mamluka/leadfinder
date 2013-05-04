'use strict';

/* Controllers */

angular.module('leadFinder.controllers', ['leadFinder.services']).

    controller('GeographicsController', ['$scope', 'Facets', 'Wizard', function ($scope, Facets, Wizard) {
        $scope.next = function () {
            window.location.href = '#demographics'
        }

    }])
    .controller('DemographicsController', ['$scope', 'Facets', function ($scope) {
        $scope.next = function () {
            window.location.href = '#psychographics'
        }
    }])
    .controller('PsychographicsController', ['$scope', 'Facets', function ($scope) {
        $scope.next = function () {
            window.location.href = '#buy'
        }
    }])
    .controller('SummeryController', ['$scope', 'Wizard', 'Leads', function ($scope, wizard, leads) {

        $scope.selectedFacetsIndicators = [];


        $scope.$on('facets-selected', function (e, data) {

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

            var selectedFacets = wizard.getSelectedFacets()
            leads.getTotalLeadsByFacets(selectedFacets).done(function (data) {
                $scope.$apply(function() {
                    $scope.total = data.total;
                })
            })
        })
    }])
;