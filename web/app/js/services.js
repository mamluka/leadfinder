'use strict';

/* Services */

angular.module('leadFinder.services', [])
    .value('apiUrl', 'http://localhost:5555')
    .factory('Facets', ['$http', 'apiUrl' , function ($http, apiUrl) {

        return {
            get: function () {
                return $http.get(apiUrl + '/facets/all')
            }
        }
    }])
    .factory('Wizard', ['$http', 'apiUrl', function ($http, apiUrl) {

        function _getSelectedFacets() {
            var state = JSON.parse(window.sessionStorage.getItem('leadFinder.wizard.state')) || {};

            var selected_facets = {};

            for (var key in state) {
                if (state.hasOwnProperty(key) && state[key] != "none")
                    selected_facets[key] = state[key]
            }

            return selected_facets;

        }

        return {
            update: function (key, value) {
                var state = JSON.parse(window.sessionStorage.getItem('leadFinder.wizard.state')) || {};
                state[key] = value;

                window.sessionStorage.setItem('leadFinder.wizard.state', JSON.stringify(state))


            },
            getAllAvailableFacets: function () {

                var selected_facets = _getSelectedFacets()

                var url = apiUrl + '/facets/get-available';
                $.getJSON(url, selected_facets).done(function (data) {
                    window.sessionStorage.setItem('leadFinder.wizard.facets.available', JSON.stringify(data));
                    $(window).trigger('facets-selected');
                })
            },
            getAvailableFacetsFor: function (facetId) {
                var facets = JSON.parse(window.sessionStorage.getItem('leadFinder.wizard.facets.available')) || {};
                return facets[facetId];
            },
            getSavedFacetFor: function (facetId) {
                var state = JSON.parse(window.sessionStorage.getItem('leadFinder.wizard.state')) || {};
                return state[facetId]
            },
            getSelectedFacets: _getSelectedFacets,
            download: function () {
                window.location.href = apiUrl + '/download/all.csv?' + jQuery.param(_getSelectedFacets());
            }

        }
    }])
    .factory('Leads', ['$http', 'apiUrl', function ($http, apiUrl) {
        return {
            getTotalLeadsByFacets: function (facets) {

                var url = apiUrl + '/leads/total';
                return $.getJSON(url, facets)
            }
        }
    }]);
