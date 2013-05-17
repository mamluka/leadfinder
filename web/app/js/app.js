'use strict';


angular.module('leadFinder', ['leadFinder.services', 'leadFinder.directives', 'leadFinder.controllers', '$strap.directives'])
    .config(function () {
        window.sessionStorage.removeItem('leadFinder.wizard.state')

    });
