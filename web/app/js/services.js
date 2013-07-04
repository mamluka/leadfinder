'use strict';

/* Services */

angular.module('leadFinder.services', ['leadFinder.apiUrl'])
    .factory('Facets', ['$http', 'apiUrl' , function ($http, apiUrl) {
        return {
            get: function () {
                var item = sessionStorage.getItem('facets-cache');
                if (item)
                    return {
                        then: function (successFunction) {
                            successFunction(JSON.parse(item));
                        }
                    };

                return $http.get(apiUrl + '/facets/all-cached')
                    .then(function (request) {
                        var data = request.data;
                        sessionStorage.setItem('facets-cache', JSON.stringify(data));

                        return data;
                    });

            },
            save: function (facets) {
                sessionStorage.setItem('facets-labels', JSON.stringify(facets));
            },
            load: function () {
                return JSON.parse(sessionStorage.getItem('facets-labels'));
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
                var value = state[facetId]

                if (typeof(value) == "undefined")
                    return false;

                value = value.toString();

                if (value && value.indexOf('-') !== -1)
                    return value.split('-');

                if (value && value.indexOf(',') > -1)
                    return value.split(',');

                if (value == "none")
                    return false;

                return value
            },
            getSelectedFacets: _getSelectedFacets,
            setExclude: function (value) {
                window.sessionStorage.setItem('leadFinder.wizard.exclude', value)
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
    .factory('DefaultSearchConfigurations', ['Wizard', 'Facets', function (wizard, facets) {
        return {
            apply: function () {
                wizard.update('has_telephone_number', 'true');
            }
        }
    }])
    .factory('Analytics', function () {
        return {
            reportFacet: function (facetLabel, value) {

                if (_.isArray(value)) {
                    value = [value[0] + " - " + value[1]]
                }

                ga('send', 'event', 'Facets', facetLabel, value);
            },
            reportNavigation: function (page) {
                ga('send', 'event', 'Navigation', 'Page', page);
            }

        }
    })
    .value('States', {
        'AL': 'Alabama',
        'AK': 'Alaska',
        'AZ': 'Arizona',
        'AR': 'Arkansas',
        'CA': 'California',
        'CO': 'Colorado',
        'CT': 'Connecticut',
        'DE': 'Delaware',
        'DC': 'District of Columbia',
        'FL': 'Florida',
        'GA': 'Georgia',
        'HI': 'Hawaii',
        'ID': 'Idaho',
        'IL': 'Illinois',
        'IN': 'Indiana',
        'IA': 'Iowa',
        'KS': 'Kansas',
        'KY': 'Kentucky',
        'LA': 'Louisiana',
        'ME': 'Maine',
        'MT': 'Montana',
        'NE': 'Nebraska',
        'NV': 'Nevada',
        'NH': 'New Hampshire',
        'NJ': 'New Jersey',
        'NM': 'New Mexico',
        'NY': 'New York',
        'NC': 'North Carolina',
        'ND': 'North Dakota',
        'OH': 'Ohio',
        'OK': 'Oklahoma',
        'OR': 'Oregon',
        'MD': 'Maryland',
        'MA': 'Massachusetts',
        'MI': 'Michigan',
        'MN': 'Minnesota',
        'MS': 'Mississippi',
        'MO': 'Missouri',
        'PA': 'Pennsylvania',
        'RI': 'Rhode Island',
        'SC': 'South Carolina',
        'SD': 'South Dakota',
        'TN': 'Tennessee',
        'TX': 'Texas',
        'UT': 'Utah',
        'VT': 'Vermont',
        'VA': 'Virginia',
        'WA': 'Washington',
        'WV': 'West Virginia',
        'WI': 'Wisconsin',
        'WY': 'Wyoming'
    })
;
