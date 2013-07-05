'use strict';

angular.module('leadFinder.controllers', ['leadFinder.services'])
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
            var data = $scope.zipList;

            var zipCodes = data.split('\n').join(',');

            wizard.update('zip', zipCodes);

            facetEvents.facetsSelected('Zip codes', zipCodes.length + ' Zips', 'geo');
            facetEvents.recalculateTotal();
        };

        $('.zip-file-uploader').upload({
            name: 'file',
            action: apiUrl + "/upload/zip-list",
            autoSubmit: true,
            onSubmit: function () {
                $('.zip-file-loader-progress').show();
            },
            onComplete: function (data) {
                $scope.$apply(function() {
                    $scope.zipList = data.join('\n')
                    $scope.loadFromForm();
                });
                $('.zip-file-loader-progress').hide();
            }

        });

    }])
    .controller('DemographicsController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {

    }])
    .controller('MortgageController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {

    }])
    .controller('EconomicsController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {

    }])
    .controller('LifestyleController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {

    }])
    .controller('SummeryController', ['$scope', 'Wizard', 'Leads', '$rootScope', function ($scope, wizard, leads, $rootScope) {


        $scope.showLeadCountChooser = false;
        $scope.countingLeads = false
        $scope.currentCallTimestamp = 0;

        $scope.$on('facets-recalculate-total', function () {

            var excludedFacets = ['has_telephone_number'];

            var selectedFacets = wizard.getSelectedFacets();

            if (_.difference(_.keys(selectedFacets), excludedFacets).length == 0) {
                $scope.showLeadCountChooser = false;
                return;
            }

            $scope.countingLeads = true;

            leads.getTotalLeadsByFacets(selectedFacets).done(function (data) {


                if ($scope.currentCallTimestamp > data.timestamp)
                    return;

                $scope.currentCallTimestamp = data.timestamp;

                $scope.$apply(function () {
                    $scope.countingLeads = false;

                    if (data.total == 0) {
                        $scope.showLeadCountChooser = false;
                        window.sessionStorage.removeItem('total-leads');

                    } else {
                        $scope.showLeadCountChooser = true;
                        $scope.total = $.formatNumber(data.total, {format: "#,###", locale: "us"});
                        $scope.pricePerLead = data.pricePerLead;

                        window.sessionStorage.setItem('total-leads', JSON.stringify({total: data.total, pricePerLead: data.pricePerLead}));
                    }
                })
            })
        });

        $scope.$broadcast('facets-recalculate-total');

        $scope.prepareToBuy = function () {


            $rootScope.$broadcast('buy-committed', {total: $scope.total, pricePerLead: $scope.pricePerLead});
            $rootScope.$broadcast('change-page', {page: 'buy'});
        }

        $rootScope.$on('change-page', function (e, data) {
            if (data.page == 'buy')
                $scope.orderFormLoaded = true;
            else
                $scope.orderFormLoaded = false;
        });

    }])
    .controller('OrderFormController', ['$scope', '$rootScope', 'BuyingLeads', function ($scope, $rootScope, buyingLeads) {

        $scope.inProgress = false;
        $scope.buyButtonText = 'Purchase Records';

        var data = JSON.parse(window.sessionStorage.getItem('total-leads'));
        if (data) {
            $scope.totalFormatted = $.formatNumber(data.total, {format: "#,###", locale: "us"});
            $scope.total = data.total;
            $scope.pricePerLead = data.pricePerLead;
        } else {
            $scope.total = 0
            $scope.pricePerLead = 1.5;
        }

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
                        content: "Your order was processed successfully, a download link will be send to: " + email,
                        type: "Info",
                        buttons: [
                            { value: "Great!" }
                        ],
                        beforeClose: function (result) {

                            $scope.$apply(function () {
                                $scope.inProgress = false;
                                $scope.buyButtonText = 'Purchase Records';
                            });
                        }
                    });

                    window.sessionStorage.removeItem('facets-labels');
                    window.sessionStorage.removeItem('leadFinder.wizard.state');
                    window.sessionStorage.removeItem('total-leads');
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