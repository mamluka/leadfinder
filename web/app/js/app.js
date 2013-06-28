'use strict';


angular.module('leadFinder', ['leadFinder.services', 'leadFinder.directives', 'leadFinder.controllers', '$strap.directives'])
    .config(function () {
        window.sessionStorage.removeItem('leadFinder.wizard.state')
    })
    .run(['Analytics', '$rootScope', function (analytics, $rootScope) {

        $rootScope.$on('change-page', function (e, data) {
            analytics.reportNavigation(data.page)
        });

    }]);
