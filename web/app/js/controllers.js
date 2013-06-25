'use strict';

angular.module('leadFinder.controllers', ['leadFinder.services']).
    controller('WizardController', ['$scope', '$rootScope', function ($scope, $rootScope) {
        $scope.showPage = true;
        $scope.displayAllTabs = true;
        $rootScope.$on('change-page', function (e, data) {
            $scope.showPage = data.page == "wizard";
        });


    }])
    .controller('GeographicsController', ['$scope', '$rootScope', 'Wizard', 'DefaultSearchConfigurations', function ($scope, $rootScope, wizard, defaultSearchConfigurations) {

        $scope.showPage = true;

        defaultSearchConfigurations.apply();

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

        $scope.$watch('selectedPaneId', function () {
            $rootScope.$broadcast('geo-include', {paneId: $scope.selectedPaneId});
        })
    }])
    .controller('StateSelectController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {
        $scope.selectedStates = [];
    }])
    .controller('NavigationController', ['$scope', '$rootScope', function ($scope, $rootScope) {

        $scope.currentPage = 'geo';
        $scope.disableOrderForm = true;

        $scope.isActive = function (page) {
            if (page == $scope.currentPage)
                return 'active'
        };

        $rootScope.$on('buy-committed', function () {
            $scope.disableOrderForm = false;
        });

        $scope.goTo = function (page) {
            if ($scope.disableOrderForm && page == 'buy') {
                $.msgBox({
                    title: "Error",
                    content: "You must select a filter before you can order",
                    type: "error",
                    showButtons: false,
                    autoClose:true
                });
                return;
            }

            $rootScope.$broadcast('change-page', {page: page});
        };

        $rootScope.$on('change-page', function (e, data) {
            $scope.currentPage = data.page
        });

    }])
    .controller('ZipSelectController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {

    }])
    .controller('SummeryController', ['$scope', 'Wizard', 'Leads', '$rootScope', function ($scope, wizard, leads, $rootScope) {


        $scope.showLeadCountChooser = false;
        $scope.countingLeads = false

        $scope.$on('facets-recalculate-total', function () {

            var excludedFacets = ['has_telephone_number'];

            var selectedFacets = wizard.getSelectedFacets();

            if (_.difference(_.keys(selectedFacets), excludedFacets).length == 0) {
                $scope.showLeadCountChooser = false;
                return;
            }

            $scope.countingLeads = true;

            leads.getTotalLeadsByFacets(selectedFacets).done(function (data) {
                $scope.$apply(function () {
                    $scope.countingLeads = false;

                    if (data.total == 0) {
                        $scope.showLeadCountChooser = false;

                    } else {
                        $scope.showLeadCountChooser = true;
                        $scope.total = $.formatNumber(data.total, {format: "#,###", locale: "us"});
                        $scope.pricePerLead = data.pricePerLead;

                        $rootScope.$broadcast('buy-committed', {total: $scope.total, pricePerLead: $scope.pricePerLead});
                    }
                })
            })
        });

        $scope.prepareToBuy = function () {
            $scope.orderFormLoaded = true

            $rootScope.$broadcast('buy-committed', {total: $scope.total, pricePerLead: $scope.pricePerLead});
            $rootScope.$broadcast('change-page', {page: 'buy'});
        }
    }])
    .controller('BuyController', ['$scope', '$rootScope', 'BuyingLeads', function ($scope, $rootScope, buyingLeads) {

        $scope.inProgress = false;
        $scope.buyButtonText = 'Purchase Records';

        $rootScope.$on('change-page', function (e, data) {
            $scope.showPage = data.page == "buy";
        });

        $rootScope.$on('buy-committed', function (e, data) {
            $scope.total = data.total;
            $scope.pricePerLead = data.pricePerLead;
        });

        $scope.isBuyButtonDisabled = function () {
            return $scope.inProgress || $scope.buyForm.$invalid
        };

        $scope.buy = function () {

            var email = $scope.email;

            var buyCall = buyingLeads.buy({
                firstName: $scope.firstName,
                lastName: $scope.lastName,
                email: email,
                ccNumber: $scope.ccNumber,
                ccMonth: $scope.ccMonth,
                ccYear: $scope.ccYear,
                ccCCV: $scope.ccCCV,
                howManyLeads: $scope.howManyLeads
            });

            $scope.inProgress = true;
            $scope.buyButtonText = 'Please wait';

            buyCall.done(function (data) {
                if (data.success) {
                    $.msgBox({
                        title: "Your order was processed",
                        content: "Your order was processed successfully, a download link will be send to:" + email,
                        type: "Info",
                        buttons: [
                            { value: "Great!" }
                        ],
                        beforeClose: function (result) {
                            window.location.reload();
                            $scope.$apply(function () {
                                $scope.inProgress = false;
                                $scope.buyButtonText = 'Purchase Records';
                            })
                        }
                    });
                } else {
                    $.msgBox({
                        title: "Something went wrong",
                        content: "There is a problem with your order: " + data.error_message,
                        type: "error",
                        buttons: [
                            { value: "Confirm" }
                        ],
                        beforeClose: function (result) {
                            $scope.$apply(function () {
                                $scope.inProgress = false;
                                $scope.buyButtonText = 'Purchase Records';
                            })
                        }
                    });
                }
            })
        }
    }]);