angular.module('leadFinder.order-form.controllers', ['leadFinder.general.services'])
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