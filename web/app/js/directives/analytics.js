angular.module('leadFinder.analytics.directives', ['leadFinder.general.services'])
    .directive('mixPanelReport', ['Analytics', function (analytics) {

        var getEventValue = function (valueType, element) {
            switch (valueType) {
                case 'value':
                    return element.val();
                    break;
                case 'boolean':
                    return 'Filled';
                    break;
                default:
                    return 'None'
            }

        };

        return {
            scope: {
                eventName: '@',
                eventTrigger: '@',
                eventValueType: '@',
                eventField: '@'
            },
            controller: function ($scope, $element) {

            },
            link: function ($scope, $element, $attr) {

                var eventName = $attr.eventName;
                var elm = $($element);

                elm.bind($attr.eventTrigger, function () {
                    var value = getEventValue($attr.eventValueType, $element);

                    analytics.report(eventName, $attr.eventField, value)
                })
            }
        };
    }
    ]);