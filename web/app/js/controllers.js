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

    }])
    .controller('DemographicsController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {

    }])
    .controller('MortgageController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {

    }])
    .controller('EconomicsController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {

    }])
    .controller('LifestyleController', ['$scope', '$rootScope', 'Wizard', 'facetEvents', function ($scope, $rootScope, wizard, facetEvents) {
        $rootScope.$broadcast('remove-loading-overlay');
    }])
    .controller('SummeryController', ['$scope', 'Wizard', 'Leads', '$rootScope', function ($scope, wizard, leads, $rootScope) {


        $scope.id = $rootScope.userId;

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
    .controller('OrderFormController', ['$scope', '$rootScope', 'BuyingLeads', '$location', 'Analytics', '$modal', function ($scope, $rootScope, buyingLeads, $location, analytics, $modal) {

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
                howManyLeads: $scope.howManyLeads,
                userId: $rootScope.userId
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
        };

        $scope.uploadSuppressionListButtonText = 'Upload suppression list(s)';
        $scope.hasSuppressionLists = false;

        var $modalScope = $rootScope.$new();
        $modalScope.files = [];
        $modalScope.userId = $rootScope.userId;

        $modalScope.browse = function () {
            $('.file-field').click();
        };

        $modalScope.$on('modal-hidden', function () {
            if ($modalScope.files.length > 0)
                $scope.$apply(function () {
                    $scope.uploadSuppressionListButtonText = 'Uploaded ' + $modalScope.files.length + ' file(s)'
                    $scope.hasSuppressionLists = true;
                });

        });

        $modalScope.$on('modal-shown', function () {

            if ($modalScope.files.length > 0)
                return;

            $('#upload').fileupload({
                dropZone: $('.upload-zone'),
                add: function (e, data) {

                    $modalScope.$apply(function () {
                        $modalScope.files.push({name: data.files[0].name, percent: 10})
                    });

                    data.scopeIndex = $modalScope.files.length - 1;

                    var jqXHR = data.submit();
                },

                progress: function (e, data) {
                    var progress = parseInt(data.loaded / data.total * 100, 10);

                    if (progress < 10)
                        return;

                    $modalScope.$apply(function () {
                        $modalScope.files[data.scopeIndex].percent = progress;
                    });


                },

                fail: function (e, data) {
                },
                done: function (e, data) {
                    $modalScope.$apply(function () {
                        $modalScope.files[data.scopeIndex].phonesCount = data.result.phonesCount;
                    });
                }
            });

        });

        $scope.uploadSuppressionList = function () {

            if ($modalScope.files.length > 0) {
                $modalScope.show();
            } else {

                $modal({
                    template: 'partials/components/upload.html',
                    show: true,
                    backdrop: 'static',
                    persist: true,
                    scope: $modalScope
                });

            }
        }
    }
    ])
    .controller('OrderReadyController', ['$scope', '$routeParams', function ($scope, $routeParams) {
        $rootScope.$broadcast('remove-loading-overlay');
        $scope.email = $routeParams['email'];
    }]);

