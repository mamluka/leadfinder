angular.module('leadFinder.summery.controller', ['leadFinder.services'])
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

    }]);