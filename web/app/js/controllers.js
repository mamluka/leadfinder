'use strict';

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

            if (_.some($scope.selectedStates, function (x) {
                return x.value == selectedState.value
            }))
                return;

            $scope.selectedStates.push(selectedState);

            var value = _.map($scope.selectedStates,function (x) {
                return x.value
            }).join(',');

            var text = _.map($scope.selectedStates,function (x) {
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

        $scope.inProgress = false;
        $scope.buyButtonText = 'Purchase Records';

        $rootScope.$on('change-page', function (e, data) {
            $scope.showPage = data.page == "buy";
        });

        $rootScope.$on('buy-committed', function (e, data) {
            $scope.howManyLeads = data.howManyLeads;
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