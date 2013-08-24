angular.module('leadFinder.general.services', ['leadFinder.apiUrl'])
    .factory('Facets', ['$http', 'apiUrl', '$rootScope' , function ($http, apiUrl, $rootScope) {

        var removeLoadingOverlay = function () {
            $rootScope.$broadcast('remove-loading-overlay');
        };

        return {
            get: function () {
                var item = sessionStorage.getItem('facets-cache');
                if (item)
                    return {
                        then: function (successFunction) {
                            successFunction(JSON.parse(item));
                            removeLoadingOverlay();
                        }
                    };

                return $http.get('/data/all-facets.json')
                    .then(function (request) {
                        var data = request.data;
                        sessionStorage.setItem('facets-cache', JSON.stringify(data));
                        removeLoadingOverlay();
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

        var geoExclude = ['zip', 'state'];

        function _getExclude() {
            return window.sessionStorage.getItem('leadFinder.wizard.exclude')
        }

        function _getSelectedFacets() {
            var state = JSON.parse(window.sessionStorage.getItem('leadFinder.wizard.state')) || {};

            var selected_facets = {};

            for (var key in state) {
                if (state.hasOwnProperty(key) && state[key] != "none")
                    selected_facets[key] = state[key]
            }

            var active = window.sessionStorage.getItem('leadFinder.wizard.active');
            if (active) {
                var facet_to_remove = _.without(geoExclude, active);
                selected_facets = _.omit(selected_facets, facet_to_remove);
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

                if (_.indexOf(geoExclude, key) > -1)
                    window.sessionStorage.setItem('leadFinder.wizard.active', key);
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
            getSelectedFacets: _getSelectedFacets
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
            buyCreditCard: function (details) {

                var facets = wizard.getSelectedFacets();

                details.facets = JSON.stringify(facets);

                var url = apiUrl + '/buy/buy-using-payjunction';
                return $.post(url, details)
            },
            buyPayPal: function (details) {
                var facets = wizard.getSelectedFacets();

                details.facets = JSON.stringify(facets);

                var url = apiUrl + '/buy/buy-using-paypal';
                return $.get(url, details)
            },
            buyUnlimited: function (details) {
                var facets = wizard.getSelectedFacets();

                details.facets = JSON.stringify(facets);

                var url = apiUrl + '/buy/unlimited';
                return $.get(url, details)
            },
            paypalSaveOrderDetails: function (data) {
                var facets = wizard.getSelectedFacets();

                var merged = $.extend(data, {
                    facets: JSON.stringify(facets)
                });

                window.sessionStorage.setItem('paypal_order', JSON.stringify(merged))

            },
            paypalExecutePayment: function (params) {

                var merged = $.extend(params, JSON.parse(window.sessionStorage.getItem('paypal_order')));

                var url = apiUrl + '/buy/paypal-payment-execute';
                return $.post(url, merged)
            }
        }
    }])
    .
    factory('facetEvents', ['$rootScope', function ($rootScope) {
        return {
            facetsSelected: function (label, value, group) {
                $rootScope.$broadcast('facets-selected', {
                    label: label,
                    value: value,
                    group: group
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
    .factory('IdGenerator', function () {
        return {
            generate: function () {
                function S4() {
                    return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
                }

                return S4() + S4() + S4() + S4() + S4() + S4();

            }
        }
    })
    .factory('Analytics', function () {

        var reportFacetsToMixPanel = function (facetLabel, value) {
            mixpanel.track('Facet Selected', {
                    facet: facetLabel,
                    value: value

                }
            );
        };

        return {
            reportFacet: function (facetLabel, value) {

                if (_.isArray(value)) {
                    value = [value[0] + " - " + value[1]]
                }

                reportFacetsToMixPanel(facetLabel, value)
                ga('send', 'event', 'Facets', facetLabel, value);
            },
            reportNavigation: function (page) {
                ga('send', 'event', 'Navigation', 'Page', page);
            },
            reportFacetDiff: function (facetLabel, existingValue, value) {
                if (value.length > 1) {

                    var diff = _.difference(value, existingValue)[0];
                    reportFacetsToMixPanel(facetLabel, diff);
                    ga('send', 'event', 'Facets', facetLabel, diff);

                } else {
                    reportFacetsToMixPanel(facetLabel, value[0]);
                    ga('send', 'event', 'Facets', facetLabel, value[0]);
                }
            },
            report: function (eventName, field, value) {

                mixpanel.track(eventName, {
                    key: field,
                    value: value

                });

                ga('send', 'event', 'OrderFormFields', field, value);
            }


        }
    })
    .factory('Authentication', ['$http', '$rootScope', 'apiUrl', function ($http, $rootScope, apiUrl) {
        return {
            getUser: function () {
                return $http.get(apiUrl + '/user/permissions', {withCredentials: true, cache: true})
            }
        }
    }]);
