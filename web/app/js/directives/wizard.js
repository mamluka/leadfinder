angular.module('leadFinder.wizard.directives', ['leadFinder.general.services'])
    .directive('listFacet', ['Facets', 'Wizard', 'facetEvents', '$rootScope', function (facets, wizard, facetEvents, $rootScope) {
        return {
            scope: {},
            controller: function ($scope, $element) {

                var elm = $($element);
                var facetId = elm.data('facet-id');
                var facetLabel = elm.data('facet-label');

                $scope.getValue = function () {
                    if (elm.prop('multiple')) {
                        var values = $('option:selected', elm)
                        if (values.length == 0)
                            return 'none';

                        return _.map(values,function (x) {
                            return $(x).val()
                        }).join(',');
                    }

                    return $('option:selected', elm).val();
                };

                $scope.getText = function () {
                    if (elm.prop('multiple')) {
                        var values = $('option:selected', elm)
                        if (values.length == 0)
                            return 'none';

                        return _.map(values,function (x) {
                            return $(x).text()
                        }).join(',');
                    }

                    return $('option:selected', elm).text();
                };

                $scope.createOption = function (text, val) {
                    var option = $('<option></option>');
                    option.val(val);
                    option.text(text);
                    return option;
                };

                $scope.updateLabel = function (set_value) {
                    var value = set_value || $scope.getText();
                    facetEvents.facetsSelected(facetLabel, value);
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

                facets.get(facetId).then(function (facets) {

                    _.each(facets[facetId], function (facet) {

                        var text = facet.text;
                        var option = $scope.createOption(text, facet.value);

                        elm.append(option)
                    });

                    elm.prepend($scope.createOption('Select', 'none'));

                    elm.chosen();

                    var savedFacet = wizard.getSavedFacetFor(facetId);
                    if (savedFacet) {
                        elm.val(savedFacet);
                        elm.trigger('liszt:updated');
                        $scope.updateLabel();
                    }
                });


                elm.change(function () {
                    $scope.updateValue();
                });
            }
        }
    }])
    .directive('checkboxListFacet', ['Facets', 'Wizard', 'facetEvents', '$rootScope', function (facets, wizard, facetEvents, $rootScope) {
        return {
            scope: {},
            controller: function ($scope, $element) {

            },
            link: function ($scope, element) {

                var elm = $(element);
                var facetId = elm.data('facet-id')
                var facetLabel = elm.data('facet-label')

                $scope.createCheckbox = function (text, val) {
                    var checkbox = $('<input></input>').attr('type', 'checkbox');
                    checkbox.attr('value', val);
                    checkbox.data('text', text);

                    return $('<label></label>')
                        .append(checkbox)
                        .append(text)
                        .addClass('state-checkbox checkbox');
                };

                $scope.getRawValue = function () {
                    var checked = $(':checked', elm);

                    return _.map(checked, function (x) {
                        return $(x).val()
                    })
                }

                $scope.getValue = function () {
                    var states = $scope.getRawValue();

                    if (states.length == 0)
                        return "none";

                    return states.join(',')
                };

                $scope.getText = function () {

                    var states = $(':checked', elm);
                    if (states.length == 0)
                        return 'none';

                    return _.map(states,function (x) {
                        return $(x).data('text')
                    }).join(',')
                };

                $scope.updateLabel = function (set_value) {
                    var value = set_value || $scope.getText();
                    facetEvents.facetsSelected(facetLabel, value, 'geo');
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

                facets.get(facetId).then(function (facets) {

                    var all_states = $scope.createCheckbox('All States', 'al,ak,az,ar,ca,co,ct,de,dc,fl,ga,hi,id,il,in,ia,ks,ky,la,me,mt,ne,nv,nh,nj,nm,ny,nc,nd,oh,ok,or,md,ma,mi,mn,ms,mo,pa,ri,sc,sd,tn,tx,ut,vt,va,wa,wv,wi,wy')
                    var all_states_checkbox = $('input[type=checkbox]', all_states);

                    elm.append(all_states);
                    all_states_checkbox.attr('all-states', true);

                    all_states_checkbox.click(function () {
                        var states = _.without($('input[type=checkbox]', elm), this);

                        if ($(this).is(':checked'))
                            _.each(states, function (x) {
                                $(x).prop('checked', false)
                            });
                    });

                    elm.append($('<div></div>').css({clear: 'both', height: '15px'}));

                    _.each(facets[facetId], function (facet) {

                        var text = facet.text;
                        var checkbox = $scope.createCheckbox(text, facet.value);

                        elm.append(checkbox)
                    });

                    $('input[type=checkbox]', elm).on('click', function () {
                        if (!$(this).attr('all-states'))
                            all_states_checkbox.prop('checked', false);

                        $scope.updateValue();
                    });

                    var savedFacet = wizard.getSavedFacetFor(facetId);
                    if (savedFacet) {
                        if (savedFacet.length == 51) {
                            all_states_checkbox.prop('checked', true);
                        } else {
                            _.each(savedFacet, function (x) {
                                $('[value=' + x + ']', elm).prop('checked', true);
                            });

                            if (!_.isArray(savedFacet))
                                $('[value=' + savedFacet + ']', elm).prop('checked', true);
                        }

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
                var smooth = elm.data('smooth');
                var facetLabelAddon = elm.data('facet-label-addon');


                facets.get(facetId).then(function (facets) {

                    var sortedFacetValues = _.sortBy(facets[facetId], function (x) {
                        return parseInt(x.value)
                    });

                    var numberOfPoints = _.size(sortedFacetValues) - 1;

                    if (lastValue) {
                        sortedFacetValues[numberOfPoints].text = lastValue
                    }

                    var modForScale = numberOfPoints > 20 ? Math.round(numberOfPoints / 15) : 5;

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

                            var minmax = null;
                            var minmax_text = null;

                            if (min == 0 && max == numberOfPoints) {
                                minmax = 'none';
                                minmax_text = 'none';
                            }


                            else {
                                if (sortedFacetValues[min].value == sortedFacetValues[max].value) {
                                    minmax = sortedFacetValues[min].value
                                    minmax_text = formatFacetLabel(sortedFacetValues[min].text)
                                }
                                else {
                                    minmax = [sortedFacetValues[min].value, sortedFacetValues[max].value];
                                    minmax_text = [formatFacetLabel(sortedFacetValues[min].text), formatFacetLabel(sortedFacetValues[max].text)];
                                }
                            }

                            wizard.update(facetId, minmax)

                            $rootScope.$apply(function () {
                                facetEvents.facetsSelected(facetLabel, minmax_text)
                                facetEvents.recalculateTotal();
                            })
                        },
                        calculate: function (value) {
                            var text = sortedFacetValues[value].text;
                            return formatValue(text);
                        }
                    });

                    var savedFacet = wizard.getSavedFacetFor(facetId);
                    if (savedFacet) {
                        var values = _.map(sortedFacetValues, function (x) {
                            return x.value.toString();
                        });
                        var min = _.indexOf(values, savedFacet[0]);
                        var max = _.indexOf(values, savedFacet[1]);

                        elm.slider("value", min, max);

                    } else {
                        elm.slider("value", 0, numberOfPoints);
                    }


                    elm.data('loaded', 'true');
                });

                function formatValue(value) {
                    if (elm.data('use-thousands')) {
                        var thousand = parseInt(value) / 1000;
                        return thousand > 999 ? (thousand / 1000) + 'M' : thousand + 'K';
                    }

                    return  value;
                }

                function formatFacetLabel(text) {
                    if (facetLabelAddon)
                        return formatValue(text) + facetLabelAddon;

                    return formatValue(text);
                }
            }
        }
    }])
    .directive('checkboxFacet', ['Facets', 'Wizard', 'facetEvents', '$rootScope', function (facets, wizard, facetEvents, $rootScope) {
        return function (scope, element) {
            var elm = $(element);
            var facetId = elm.data('facet-id')
            var facetLabel = elm.data('facet-label')
            var unchecked_value = elm.data('unchecked-value');

            var savedFacet = wizard.getSavedFacetFor(facetId);
            if (savedFacet && savedFacet != "none" && !unchecked_value) {
                elm.prop('checked', true);
                facetEvents.facetsSelected(facetLabel, 'Yes');
            }

            elm.change(function () {
                var self = $(this);
                var label = self.is(':checked') ? "Yes" : 'none';
                var value = self.is(':checked') ? self.data('checked-value') : unchecked_value || 'none';

                wizard.update(facetId, value);
                $rootScope.$apply(function () {
                    facetEvents.facetsSelected(facetLabel, label);
                    facetEvents.recalculateTotal();
                })
            });

        }
    }])
    .directive('respondLevelFacet', ['Facets', 'Wizard', 'facetEvents', '$rootScope', '$modal', function (facets, wizard, facetEvents, $rootScope, $modal) {
        var translate = {
            cdr_connected: 'Phone verified',
            cdr_seconds_30: 'Responder',
            cdr_seconds_300: 'Premium Responder',
            none: 'none'

        }
        return {
            scope: {},
            controller: function ($scope, $element) {
                $scope.help = function () {
                    var $helpScope = $rootScope.$new();

                    $modal({
                        template: 'partials/help/response-level.html',
                        show: true,
                        backdrop: 'static',
                        persist: true,
                        scope: $helpScope
                    });
                }
            },
            link: function ($scope, element) {
                var elm = $(element);
                var facetId = elm.data('facet-id');
                var facetLabel = elm.data('facet-label');

                var savedFacet = wizard.getSavedFacetFor(facetId);
                if (savedFacet) {
                    $scope.responseLevel = savedFacet
                }

                $scope.$watch('responseLevel', function (newValue) {
                    if (newValue) {
                        wizard.update(facetId, newValue);
                        facetEvents.facetsSelected(facetLabel, translate[newValue]);
                        facetEvents.recalculateTotal();
                    }
                });
            },
            replace: true,
            templateUrl: 'partials/components/respond-level.html'
        }
    }]);