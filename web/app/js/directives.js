'use strict';

/* Directives */


angular.module('leadFinder.directives', ['leadFinder.services'])
    .factory('facetEvents', ['$rootScope', function ($rootScope) {
        return {
            facetsSelected: function (label, value, id) {
                $rootScope.$broadcast('facets-selected', {
                    label: label,
                    value: value,
                    id: id
                });
            }
        }
    }])
    .directive('listFacet', ['Facets', 'Wizard', 'facetEvents', '$rootScope', function (facets, wizard, facetEvents, $rootScope) {
        return function (scope, element) {

            var elm = $(element);
            var facetId = elm.data('facet-id')
            var facetLabel = elm.data('facet-label')

            facets.get(facetId).success(function (facets) {

                _.each(facets[facetId], function (facet) {

                    var text = facet.text;
                    var option = createOption(text, facet.value, facetId)

                    elm.append(option)
                });

                elm.prepend(createOption('Select', 'none'))

                var savedFacet = wizard.getSavedFacetFor(facetId)
                if (savedFacet) {
                    elm.val(savedFacet)
                    facetEvents.facetsSelected(facetLabel, savedFacet, facetId)
                }
            });

            elm.change(function () {
                var self = $(this)
                var value = $('option:selected', self).val()

                wizard.update(facetId, value);
                $rootScope.$apply(function () {
                    facetEvents.facetsSelected(facetLabel, value, facetId)
                })
            });

            $scope.$on('')

            function createOption(text, val) {
                var option = $('<option></option>');
                option.val(val)
                option.text(text)
                return option
            }
        }
    }])
    .directive('sliderFacet', ['Facets', 'Wizard', 'facetEvents', '$rootScope', function (facets, wizard, facetEvents, $rootScope) {
        return function (scope, element) {

            var elm = $(element);
            var facetId = elm.data('facet-id')
            var facetLabel = elm.data('facet-label')

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
                        })
                    }

                })

                var savedFacet = wizard.getSavedFacetFor(facetId)
                if (savedFacet) {

                    elm.slider("values", savedFacet);

                    facetEvents.facetsSelected(facetLabel, savedFacet, facetId)
                }
            });
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
                    facetEvents.facetsSelected(facetLabel, value, facetId)
                })
            });

        }
    }])
    .directive('multilineFacet', ['Facets', 'Wizard', 'facetEvents', '$rootScope', function (facets, wizard, facetEvents, $rootScope) {
        return function (scope, element) {
            var elm = $(element);
            var facetId = elm.data('facet-id')
            var facetLabel = elm.data('facet-label')

            var savedFacet = wizard.getSavedFacetFor(facetId)
            if (savedFacet) {
                elm.val(savedFacet)
                facetEvents.facetsSelected(facetLabel, savedFacet, facetId)
            }

            elm.blur(function () {
                var self = $(this)

                var value = self.val().split('\n').join(',')

                wizard.update(facetId, value);
                $rootScope.$apply(function () {
                    facetEvents.facetsSelected(facetLabel, value, facetId)
                })
            });

        }
    }])
    .directive('tabs',function () {
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