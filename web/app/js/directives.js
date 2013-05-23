'use strict';

/* Directives */


angular.module('leadFinder.directives', ['leadFinder.services'])
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

                $scope.getText = function () {
                    return $('option:selected', elm).html();
                };

                $scope.createOption = function (text, val) {
                    var option = $('<option></option>');
                    option.val(val);
                    option.text(text);
                    return option;
                };

                $scope.updateLabel = function (set_value) {
                    var value = set_value || $scope.getText();
                    facetEvents.facetsSelected(facetLabel, value, facetId);
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
    }]).directive('displayListFacet', ['Facets', 'Wizard', 'facetEvents', '$rootScope', function (facets, wizard, facetEvents, $rootScope) {
        return {
            scope: { selectedData: '=', exclude: '='},
            link: function ($scope, element) {

                var elm = $(element);
                var facetId = elm.data('facet-id')
                var facetLabel = elm.data('facet-label')

                $scope.createOption = function (text, val) {
                    var option = $('<option></option>');
                    option.val(val);
                    option.text(text);
                    return option;
                };

                $scope.getValue = function () {
                    return $('option:selected', elm).val();
                };

                $scope.getText = function () {
                    return $('option:selected', elm).html();
                };

                $scope.updateLabel = function (set_value) {
                    var value = set_value || $scope.getText();
                    facetEvents.facetsSelected(facetLabel, value, facetId);
                };

                facets.get(facetId).success(function (facets) {

                    _.each(facets[facetId], function (facet) {

                        var text = facet.text;
                        var option = $scope.createOption(text, facet.value);

                        elm.append(option)
                    });

                    elm.prepend($scope.createOption('Select', 'none'));
                });

                elm.change(function () {
                    $scope.$apply(function () {
                        $scope.selectedData = {
                            text: $('option:selected', elm).html(),
                            value: $('option:selected', elm).val(),
                            facetId: facetId,
                            facetLabel: facetLabel
                        }
                    });
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
    .directive('coolSliderFacet', ['Facets', 'Wizard', 'facetEvents', '$rootScope', function (facets, wizard, facetEvents, $rootScope) {
        return{
            link: function ($scope, $element) {
                var elm = $($element)
                var facetId = elm.data('facet-id');
                var facetLabel = elm.data('facet-label');
                var lastValue = elm.data('facet-last-value');
                var handleLabel = elm.data('facet-handle-label')
                var smooth = elm.data('smooth')


                facets.get(facetId).success(function (facets) {

                    var sortedFacetValues = _.sortBy(facets[facetId], function (x) {
                        return parseInt(x.value)
                    });

                    var numberOfPoints = _.size(sortedFacetValues) - 1;

                    if (lastValue) {
                        sortedFacetValues[numberOfPoints].text = lastValue
                    }

                    var modForScale = numberOfPoints > 20 ? Math.round(numberOfPoints / 20) : 4;

                    var scale = _.map(sortedFacetValues, function (x, i) {
                        if (i % modForScale == 0) {
                            return formatValue(x.text)
                        }

                        return '|';
                    });

                    elm.slider({
                        from: 0,
                        to: numberOfPoints,
                        scale: scale,
                        step: 1,
                        smooth: smooth || false,
                        dimension: '&nbsp;' + handleLabel,
                        callback: function (value) {
                            var values = value.split(';');
                            var min = values[0]
                            var max = values[1];

                            var minmax;

                            if (min == 0 && max == numberOfPoints)
                                minmax = 'none';
                            else
                                minmax = [sortedFacetValues[min].value, sortedFacetValues[max].value];

                            wizard.update(facetId, minmax)

                            $rootScope.$apply(function () {
                                facetEvents.facetsSelected(facetLabel, minmax, facetId)
                                facetEvents.recalculateTotal();
                            })
                        },
                        calculate: function (value) {
                            var text = sortedFacetValues[value].text;
                            return formatValue(text);
                        }
                    });

                    elm.slider("value", 0, numberOfPoints);
                    elm.data('loaded', 'true');
                });

                function formatValue(value) {
                    if (elm.data('use-thousands'))
                        return parseInt(value) / 100 + 'K';

                    return  value;
                }
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
                var label = self.is(':checked') ? "Yes" : 'none';
                var value = self.is(':checked') ? self.data('checked-value') : 'none';

                wizard.update(facetId, value);
                $rootScope.$apply(function () {
                    facetEvents.facetsSelected(facetLabel, label, facetId);
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
    }])
    .directive('tabs', function () {
        return {
            restrict: 'E',
            scope: {
                displayTabs: '=',
                displayAllTabs: '='
            },
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

                $scope.$watch('displayAllTabs', function () {
                    if ($scope.displayAllTabs) {
                        _.each(panes, function (x) {
                            x.selected = true;
                        })
                    }
                    else {
                        $scope.select(panes[0])
                    }

                });
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
    })

    .directive('pane', function () {
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
    .directive('facets', function () {
        return {
            restrict: 'E',
            controller: function ($scope, $element) {

                $scope.selectedFacetsIndicators = [];

                $scope.$on('facets-selected', function (e, data) {

                    if (data.value == "none" || data.value == "Select") {
                        $scope.selectedFacetsIndicators = _.reject($scope.selectedFacetsIndicators, function (x) {
                            return x.label == data.label;
                        });
                        return;
                    }

                    var alreadyUsed = _.some($scope.selectedFacetsIndicators, function (x) {
                        return x.label == data.label
                    });

                    if (alreadyUsed) {
                        $scope.selectedFacetsIndicators = _.map($scope.selectedFacetsIndicators, function (x) {
                            if (x.label == data.label) {
                                x.values = format(data.value);
                                return x;
                            }
                            return x;
                        })
                    }
                    else {
                        $scope.selectedFacetsIndicators.push({label: data.label, values: format(data.value)});
                    }

                    function format(value) {
                        if (_.isArray(value)) {
                            return [value[0] + " - " + value[1]]
                        }

                        if (value.indexOf(',') > -1)
                            return value.split(',')

                        return [value];
                    }
                });

            },
            templateUrl: 'partials/components/facets.html',
            transclude: true,
            replace: true
        };
    })
    .directive('chooseNumberOfLeads', function () {
        return {
            scope: {
                howManyLeads: '=',
                pricePerLead: '='

            },
            transclude: true,
            controller: function ($scope, $element) {

                $scope.$watch('howManyLeads', function () {
                    $scope.totalPrice = $.formatNumber($scope.howManyLeads * $scope.pricePerLead / 1000);
                });

            },
            templateUrl: 'partials/components/choose-how-many-leads.html',
            replace: true
        };
    });
