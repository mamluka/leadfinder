'use strict';

/* Controllers */

angular.module('leadFinder.controllers', ['leadFinder.services']).
    controller('WizardController', ['$scope', '$rootScope', function ($scope, $rootScope) {
        $scope.showPage = true;
        $scope.displayAllTabs = true;
        $rootScope.$on('change-page', function (e, data) {
            $scope.showPage = data.page == "wizard";
        });


    }])
    .controller('GeographicsController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {

        $scope.showPage = true;

        $scope.next = function () {

            var facets = wizard.getSelectedFacets();

            if (facets.hasOwnProperty('state') || facets.hasOwnProperty('zip')) {
                $rootScope.$broadcast('change-page', {page: 'wizard'});
            } else {
                alert('Please select a state or a zip list')
            }
        };

        $rootScope.$on('change-page', function (e, data) {
            $scope.showPage = data.page == "geo";
        });

        $scope.selectedStates = [];

        $scope.addState = function () {
            var selectedState = $scope.selectedState;

            if (!selectedState || selectedState.value === "none") {
                alert('Please select a state to add');
                return;
            }

            $scope.selectedStates.push(selectedState);

            var value = _.map($scope.selectedStates, function (x) {
                return x.value
            }).join(',');

            var text = _.map($scope.selectedStates, function (x) {
                return x.text
            }).join(',');

            wizard.update(selectedState.facetId, value);
            facetEvents.facetsSelected(selectedState.facetLabel, text, selectedState.facetId);
            facetEvents.recalculateTotal();
        }

    }])
    .controller('SummeryController', ['$scope', 'Wizard', 'Leads', '$rootScope', function ($scope, wizard, leads, $rootScope) {


        $scope.showLeadCountChooser = false;

        $scope.$on('facets-recalculate-total', function () {

            var selectedFacets = wizard.getSelectedFacets();

            leads.getTotalLeadsByFacets(selectedFacets).done(function (data) {
                $scope.$apply(function () {
                    $scope.total = data.total;
                    $scope.pricePerLead = data.pricePerLead;
                    $scope.showLeadCountChooser = true;
                    $scope.howManyLeads = data.total;
                })
            })
        });

        $scope.prepareToBuy = function () {

            if ($scope.howManyLeads > $scope.total) {
                alert("Yuo can't buy more leads then we have!");
                return;
            }

            $rootScope.$broadcast('buy-committed', {howManyLeads: $scope.howManyLeads, pricePerLead: $scope.pricePerLead});
            $rootScope.$broadcast('change-page', {page: 'buy'});
        }
    }])
    .controller('BuyController', ['$scope', '$rootScope', 'BuyingLeads', function ($scope, $rootScope, buyingLeads) {

        $rootScope.$on('change-page', function (e, data) {
            $scope.showPage = data.page == "buy";
        });

        $rootScope.$on('buy-committed', function (e, data) {
            $scope.howManyLeads = data.howManyLeads;
            $scope.pricePerLead = data.pricePerLead;
        });

        $scope.buy = function () {


            buyingLeads.buy({
                firstName: $scope.firstName,
                lastName: $scope.lastName,
                email: $scope.email,
                ccNumber: $scope.ccNumber,
                ccMonth: $scope.ccMonth,
                ccYear: $scope.ccYear,
                ccCCV: $scope.ccCCV,
                howManyLeads: $scope.howManyLeads
            })
        }


    }]);