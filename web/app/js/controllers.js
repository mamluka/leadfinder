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
                $('zip-file-uploader').prop('disabled', true);
            },
            onComplete: function (data) {
                $scope.$apply(function () {
                    $scope.loadingInProgress = false;
                    $scope.zipList = data.join('\n')
                    $scope.loadFromForm();
                });

                $('.zip-file-loader-progress').hide();
                $('zip-file-uploader').prop('disabled', false);
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
                });

                $rootScope.$broadcast('facets-recalculate-total-finished');
            })
        });

        $scope.$broadcast('facets-recalculate-total');

        $scope.prepareToBuy = function () {


            $rootScope.$broadcast('buy-committed', {total: $scope.total, pricePerLead: $scope.pricePerLead});
            $rootScope.$broadcast('change-page', {page: 'buy'});
        };

        $rootScope.$on('change-page', function (e, data) {
            if (data.page == 'buy')
                $scope.orderFormLoaded = true;
            else
                $scope.orderFormLoaded = false;
        });

    }])
    .controller('OrderFormController', ['$scope', '$rootScope', 'BuyingLeads', '$location', 'Analytics', function ($scope, $rootScope, buyingLeads, $location, analytics) {

        $rootScope.$broadcast('remove-loading-overlay');

        $scope.inProgress = false;
        $scope.buyButtonText = 'Purchase Records';

        var data = JSON.parse(window.sessionStorage.getItem('total-leads'));
        if (data) {
            $scope.totalFormatted = $.formatNumber(data.total, {format: "#,###", locale: "us"});
            $scope.total = data.total;
            $scope.pricePerLead = data.pricePerLead;
        } else {
            $scope.total = 0;
            $scope.pricePerLead = 1.5;
        }

        $scope.isBuyButtonDisabled = function () {
            return $scope.inProgress || $scope.buyForm.$invalid
        };

        $scope.buy = function () {

            analytics.report('Order', 'Process', 'Made Purchase');

            var email = $scope.email;

            var buyCall = buyingLeads.buy({
                firstName: $scope.firstName,
                lastName: $scope.lastName,
                email: email,
                ccNumber: $('.cc-number').val(),
                ccMonth: $scope.ccMonth,
                ccYear: $scope.ccYear,
                ccCCV: $scope.ccCCV,
                howManyLeads: $scope.howManyLeads
            });

            $scope.inProgress = true;
            $scope.buyButtonText = 'Please wait';

            buyCall.done(function (data) {
                if (data.success) {
                    $scope.$apply(function () {

                        PostAffTracker.setAccountId('default1');
                        var sale = PostAffTracker.createSale();
                        sale.setTotalCost(data.amount);
                        sale.setOrderID(data.orderId);

                        PostAffTracker.register();

                        analytics.report('Order', 'Process', 'Success');

                        $location.path('/order-form/order-ready').search({email: email}).replace();
                    });
                } else {
                    analytics.report('Order', 'Process', 'Failed');

                    $scope.$apply(function () {
                        $scope.error_message = data.error_message;
                        $scope.error = true;
                        $scope.inProgress = false;
                    });
                }
            })
        }
    }])
    .controller('OrderReadyController', ['$scope', '$routeParams', function ($scope, $routeParams) {
        $scope.email = $routeParams['email'];
    }]);
