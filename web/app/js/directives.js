'use strict';

/* Directives */


angular.module('leadFinder.directives', ['leadFinder.services'])
    .factory('facetEvents', ['$rootScope', function ($rootScope) {
        return {
            facetsSelected: function (label, value, id, opt) {
                $rootScope.$broadcast('facets-selected', {
                    label: label,
                    value: value,
                    id: id
                });
            },
            recalculateTotal: function () {
                $rootScope.$broadcast('facets-recalculate-total');
            }
        }
    }])
    .directive('listFacet', ['Facets', 'Wizard', 'facetEvents', '$rootScope', function (facets, wizard, facetEvents, $rootScope) {
        return {
            scope: {exclude: '='},
            controller: function ($scope, $element) {

                var elm = $($element);
                var facetId = elm.data('facet-id');
                var facetLabel = elm.data('facet-label');

                $scope.getValue = function () {
                    return $('option:selected', elm).val();
                };

                $scope.createOption = function (text, val) {
                    var option = $('<option></option>');
                    option.val(val);
                    option.text(text);
                    return option;
                };

                $scope.updateLabel = function (set_value) {
                    var value = set_value || $scope.getValue();
                    facetEvents.facetsSelected(facetLabel, value, facetId)
                };

                $scope.updateState = function () {
                    var value = $scope.getValue();
                    wizard.update(facetId, value);
                };

                $scope.recalculateTotal = function () {
                    facetEvents.recalculateTotal();
                };

                $scope.updateValue = function () {

                    $scope.updateState();

                    if (!$rootScope.$$phase) {
                        $rootScope.$apply(function () {
                            $scope.updateLabel();
                            $scope.recalculateTotal();
                        });
                    }
                    else {
                        $scope.updateLabel();
                        $scope.recalculateTotal();
                    }

                };
            },
            link: function ($scope, element) {

                var elm = $(element);
                var facetId = elm.data('facet-id')
                var facetLabel = elm.data('facet-label')

                facets.get(facetId).success(function (facets) {

                    _.each(facets[facetId], function (facet) {

                        var text = facet.text;
                        var option = $scope.createOption(text, facet.value);

                        elm.append(option)
                    });

                    elm.prepend($scope.createOption('Select', 'none'));

                    var savedFacet = wizard.getSavedFacetFor(facetId);
                    if (savedFacet) {
                        elm.val(savedFacet);
                        $scope.updateLabel(savedFacet);
                    }
                });


                elm.change(function () {
                    $scope.updateValue();
                });

                $scope.$watch('exclude', function () {
                    if ($scope.exclude == facetId) {
                        $scope.updateLabel("none");
                    }
                    else if ($scope.exclude) {
                        $scope.updateLabel();
                    }
                });
            }
        }
    }])
    .directive('sliderFacet', ['Facets', 'Wizard', 'facetEvents', '$rootScope', function (facets, wizard, facetEvents, $rootScope) {
        return{
            link: function (scope, element) {

                var elm = $(element);
                var facetId = elm.data('facet-id');
                var facetLabel = elm.data('facet-label');

                facets.get(facetId).success(function (facets) {

                    var sortedFacetValues = _.sortBy(facets[facetId], function (x) {
                        return parseInt(x.value)
                    });

                    var numberOfPoints = _.size(sortedFacetValues) - 1;

                    elm.slider({
                        range: true,
                        min: 0,
                        max: numberOfPoints,
                        values: [ 0, numberOfPoints],
                        stop: function (event, ui) {
                            var min = ui.values[0];
                            var max = ui.values[1];
                            var minmax = [sortedFacetValues[min].value, sortedFacetValues[max].value]

                            wizard.update(facetId, minmax)

                            $rootScope.$apply(function () {
                                facetEvents.facetsSelected(facetLabel, minmax, facetId)
                                facetEvents.recalculateTotal();
                            })
                        }

                    })

                    var savedFacet = wizard.getSavedFacetFor(facetId)
                    if (savedFacet) {

                        var min = _.find(sortedFacetValues, function (x) {
                            return x.value == savedFacet[0];
                        });

                        min = sortedFacetValues.indexOf(min);

                        var max = _.find(sortedFacetValues, function (x) {
                            return x.value == savedFacet[1];
                        });

                        max = sortedFacetValues.indexOf(max);

                        elm.slider("values", [min, max]);

                        facetEvents.facetsSelected(facetLabel, savedFacet, facetId)
                    }
                });
            }
        }
    }])
    .directive('checkboxFacet', ['Facets', 'Wizard', 'facetEvents', '$rootScope', function (facets, wizard, facetEvents, $rootScope) {
        return function (scope, element) {
            var elm = $(element);
            var facetId = elm.data('facet-id')
            var facetLabel = elm.data('facet-label')

            var savedFacet = wizard.getSavedFacetFor(facetId)
            if (savedFacet && savedFacet != "none") {
                elm.prop('checked', true);
                facetEvents.facetsSelected(facetLabel, savedFacet, facetId)
            }

            elm.change(function () {
                var self = $(this)
                var value = self.is(':checked') ? self.data('checked-value') : 'none';

                wizard.update(facetId, value);
                $rootScope.$apply(function () {
                    facetEvents.facetsSelected(facetLabel, value, facetId);
                    facetEvents.recalculateTotal();
                })
            });

        }
    }])
    .directive('multilineFacet', ['Facets', 'Wizard', 'facetEvents', '$rootScope', function (facets, wizard, facetEvents, $rootScope) {
        return  {
            scope: {exclude: '='},
            controller: function ($scope, $element) {
                var elm = $($element);
                var facetId = elm.data('facet-id')
                var facetLabel = elm.data('facet-label')

                $scope.getValue = function () {
                    var value = elm.val().split('\n').join(',');
                    if (value.length == 0)
                        return 'none';

                    return  value;
                };

                $scope.updateLabel = function (set_value) {
                    var value = set_value || $scope.getValue();
                    facetEvents.facetsSelected(facetLabel, value, facetId)
                };

                $scope.updateState = function () {
                    var value = $scope.getValue();
                    wizard.update(facetId, value);
                };

                $scope.recalculateTotal = function () {
                    facetEvents.recalculateTotal();
                };

                $scope.updateValue = function () {

                    $scope.updateState();

                    if (!$rootScope.$$phase) {
                        $rootScope.$apply(function () {
                            $scope.updateLabel()
                            $scope.recalculateTotal();
                        });
                    }
                    else {
                        $scope.updateLabel()
                        $scope.recalculateTotal();
                    }

                };

            },
            link: function ($scope, element) {
                var elm = $(element);
                var facetId = elm.data('facet-id')
                var facetLabel = elm.data('facet-label')

                var savedFacet = wizard.getSavedFacetFor(facetId)
                if (savedFacet) {
                    elm.val(savedFacet.split(',').join('\n'))
                    $scope.updateValue(savedFacet);
                }

                elm.blur(function () {
                    $scope.updateValue();
                });

                $scope.$watch('exclude', function () {
                    if ($scope.exclude == facetId) {
                        $scope.updateLabel("none");
                    }
                    else if ($scope.exclude) {
                        console.log($scope.exclude)
                        $scope.updateLabel();
                    }
                });
            }
        }
    }])
    .directive('facetExcluder', ['Facets', 'Wizard', 'facetEvents', '$rootScope', function (facets, wizard, facetEvents, $rootScope) {
        return  {
            scope: {exclude: '='},
            link: function ($scope, $element) {
                var elm = $($element);
                var facetId = elm.data('facet-id');

                elm.change(function () {
                    $scope.$apply(function () {
                        $scope.exclude = elm.val();
                    });
                    wizard.setExclude(elm.val());
                    facetEvents.recalculateTotal();
                });

            }}
    }]).
    directive('tabs',function () {
        return {
            restrict: 'E',
            scope: {displayTabs: '='},
            transclude: true,
            controller: function ($scope, $element) {
                var panes = $scope.panes = [];

                $scope.select = function (pane) {
                    angular.forEach(panes, function (pane) {
                        pane.selected = false;
                    });
                    pane.selected = true;
                }

                this.addPane = function (pane) {
                    if (panes.length == 0) $scope.select(pane);
                    panes.push(pane);
                }
            },
            template: '<div class="tabbable" ng-show="displayTabs">' +
                '<ul class="nav nav-tabs">' +
                '<li ng-repeat="pane in panes" ng-class="{active:pane.selected}">' +
                '<a href="" ng-click="select(pane)">{{pane.title}}</a>' +
                '</li>' +
                '</ul>' +
                '<div class="tab-content" ng-transclude></div>' +
                '</div>',
            replace: true
        };
    }).
    directive('pane', function () {
        return {
            require: '^tabs',
            restrict: 'E',
            transclude: true,
            scope: { title: '@' },
            link: function (scope, element, attrs, tabsCtrl) {
                tabsCtrl.addPane(scope);
            },
            template: '<div class="tab-pane" ng-class="{active: selected}" ng-transclude>' +
                '</div>',
            replace: true
        };
    })
    .directive('rangeSlider', function () {
        return {
            restrict: 'A',
            scope: {
                min: '=minValue',
                test: '@test'
            },
            link: function (scope, element) {
                alert(scope.test)
                $(element).slider({
                    range: true,
                    min: 0,
                    max: 500,
                    values: [ 75, 300 ],
                    slide: function (event, ui) {
                        scope.$apply(function () {
                            scope.min = ui.values[0];
                        })
                    }
                });
            }
        }
    });