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
    .controller('GeographicsController', ['$scope', '$rootScope', 'Wizard', function ($scope, $rootScope, wizard) {

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

    }])
    .controller('SummeryController', ['$scope', 'Wizard', 'Leads', '$rootScope', function ($scope, wizard, leads, $rootScope) {


        $scope.howManyLeads = 1000;
        $scope.showLeadCountChooser = false;

        $scope.$on('facets-recalculate-total', function () {

            var selectedFacets = wizard.getSelectedFacets();

            leads.getTotalLeadsByFacets(selectedFacets).done(function (data) {
                $scope.$apply(function () {
                    $scope.total = data.total;
                    $scope.pricePerLead = data.pricePerLead;
                    $scope.showLeadCountChooser = true;
                })
            })
        });

        $scope.prepareToBuy = function () {
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