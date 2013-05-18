'use strict';

/* Services */

angular.module('leadFinder.services', [])
    .value('apiUrl', 'http://localhost:5555')
    .factory('Facets', ['$http', 'apiUrl' , function ($http, apiUrl) {

        return {
            get: function () {
                return $http.get(apiUrl + '/facets/all-cached')
            }
        }
    }])
    .factory('Wizard', ['$http', 'apiUrl', function ($http, apiUrl) {

        function _getExclude() {
            return window.sessionStorage.getItem('leadFinder.wizard.exclude')
        }

        function _getSelectedFacets() {
            var state = JSON.parse(window.sessionStorage.getItem('leadFinder.wizard.state')) || {};

            var selected_facets = {};

            for (var key in state) {
                if (state.hasOwnProperty(key) && state[key] != "none" && key != _getExclude())
                    selected_facets[key] = state[key]
            }

            return selected_facets;

        }

        return {
            update: function (key, value) {
                var state = JSON.parse(window.sessionStorage.getItem('leadFinder.wizard.state')) || {};
                if (_.isArray(value)) {
                    state[key] = value[0] + '-' + value[1]
                }
                else {
                    state[key] = value;
                }

                window.sessionStorage.setItem('leadFinder.wizard.state', JSON.stringify(state))


            },
            getSavedFacetFor: function (facetId) {
                var state = JSON.parse(window.sessionStorage.getItem('leadFinder.wizard.state')) || {};
                var value = state[facetId];

                if (value && value.indexOf('-') !== -1)
                    return value.split('-')

                return value
            },
            getSelectedFacets: _getSelectedFacets,
            download: function () {
                window.location.href = apiUrl + '/download/all.csv?' + jQuery.param(_getSelectedFacets());
            },
            setExclude: function (value) {
                window.sessionStorage.setItem('leadFinder.wizard.exclude', value)
            },
            getExclude: _getExclude,
            clear: function () {
                window.sessionStorage.removeItem('leadFinder.wizard.state')
            }
        }
    }])
    .factory('Leads', ['$http', 'apiUrl', function ($http, apiUrl) {
        return {
            getTotalLeadsByFacets: function (facets) {

                var url = apiUrl + '/leads/total';
                return $.post(url, facets)
            }
        }
    }])
    .factory('BuyingLeads', ['$http', 'apiUrl', 'Wizard', function ($http, apiUrl, wizard) {
        return {
            buy: function (details) {

                var facets = wizard.getSelectedFacets();

                details.facets = JSON.stringify(facets);

                var url = apiUrl + '/buy/buy';
                return $.post(url, details)
            }
        }
    }])
    .factory('facetEvents', ['$rootScope', function ($rootScope) {
        return {
            facetsSelected: function (label, value, id) {
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
;
