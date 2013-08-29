angular.module('leadFinder.order-form.directives', ['leadFinder.general.services'])
    .directive('facets', ['Analytics', 'Facets', function (analytics, facets) {
        return {
            restrict: 'E',
            controller: function ($scope, $element) {

                var saved_facets = facets.load();
                $scope.selectedFacetsIndicators = saved_facets || [];


                $scope.$on('facets-selected', function (e, data) {

                    if (data.value == "none" || data.value == "Select") {
                        $scope.selectedFacetsIndicators = _.reject($scope.selectedFacetsIndicators, function (x) {
                            return x.label == data.label;
                        });
                        saveFacets();

                        return;
                    }

                    $scope.selectedFacetsIndicators = _.filter($scope.selectedFacetsIndicators, function (facet) {
                        return !(facet.group && data.group === facet.group && data.label !== facet.label);
                    });

                    var alreadyUsed = _.some($scope.selectedFacetsIndicators, function (x) {
                        return x.label == data.label
                    });

                    if (alreadyUsed) {
                        $scope.selectedFacetsIndicators = _.map($scope.selectedFacetsIndicators, function (x) {
                            if (x.label == data.label) {
                                var values = format(data.value);
                                analytics.reportFacetDiff(data.label, x.values, values);

                                x.values = values;

                                return x;
                            }
                            return x;
                        })
                    }
                    else {
                        $scope.selectedFacetsIndicators.push({label: data.label, values: format(data.value), group: data.group});
                        analytics.reportFacet(data.label, data.value)
                    }

                    saveFacets();

                    function format(value) {
                        if (_.isArray(value)) {
                            return [value[0] + " - " + value[1]]
                        }

                        if (typeof(value) == 'string' && value.indexOf(',') > -1)
                            return value.split(',')

                        return [value];
                    }

                    function saveFacets() {
                        facets.save(_.map($scope.selectedFacetsIndicators, function (x) {
                            return { label: x.label, values: x.values, group: x.group }
                        }));
                    }
                });
            },
            templateUrl: 'partials/components/facets.html',
            transclude: true,
            replace: true
        };
    }])
    .directive('chooseNumberOfLeads', function () {
        return {
            scope: {
                howManyLeads: '=',
                pricePerLead: '=',
                total: '='

            },
            transclude: true,
            controller: function ($scope, $element) {

                $scope.max = $scope.total > 1000000 ? 1000000 : $scope.total;

                $scope.$watch('howManyLeads', function () {
                    $scope.totalPrice = $.formatNumber($scope.howManyLeads * $scope.pricePerLead / 100);
                });
            },
            templateUrl: 'partials/components/choose-how-many-leads.html',
            replace: true
        };
    })
    .directive('ngMax', function () {
        return {
            restrict: 'A',
            require: 'ngModel',
            link: function (scope, elem, attr, ctrl) {

                function isEmpty(value) {
                    return angular.isUndefined(value) || value === '' || value === null || value !== value;
                }

                scope.$watch(attr.ngMax, function () {
                    ctrl.$setViewValue(ctrl.$viewValue);
                });
                var maxValidator = function (value) {
                    var max = scope.$eval(attr.ngMax) || Infinity;
                    if (!isEmpty(value) && value > max) {
                        ctrl.$setValidity('ngMax', false);
                        return undefined;
                    } else {
                        ctrl.$setValidity('ngMax', true);
                        return value;
                    }
                };

                ctrl.$parsers.push(maxValidator);
                ctrl.$formatters.push(maxValidator);
            }
        };
    })
    .directive('creditCardValidation', function ($modal) {
        return {
            require: 'ngModel',
            link: function (scope, elm, attrs, ctrl) {
                ctrl.$parsers.unshift(function (viewValue) {
                    var validation = creditCardValidator.validate_number(viewValue);

                    if (validation.length_valid && validation.length_valid)
                        ctrl.$setValidity('creditCard', true);
                    else
                        ctrl.$setValidity('creditCard', false);
                });
            }
        };
    });