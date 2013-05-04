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

                    var text = facet.id;
                    var option = createOption(text, facet.id, facetId)

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

            function createOption(text, val) {
                var option = $('<option></option>');
                option.val(val)
                option.text(text)
                return option
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
                    facetEvents.facetsSelected(facetLabel, value, facetId)
                })
            });

        }
    }])
    .directive('tabs',function () {
        return {
            restrict: 'E',
            transclude: true,
            scope: {},
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
            template: '<div class="tabbable">' +
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
    });
