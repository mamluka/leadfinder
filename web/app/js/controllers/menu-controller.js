angular.module('leadFinder.login.controller', ['leadFinder.general.services'])
    .controller('MenuController', [ '$scope', '$rootScope', '$modal', function ($scope, $rootScope, $modal) {

        $scope.loginInformationPresent = false;
        $scope.loggedIn = false;

        $rootScope.$on('user-status-retrieved', function (ev, user) {
            $scope.loginInformationPresent = true;
            $scope.loggedIn = user.authenticated && user.found;
        });

        $scope.login = function () {

            var $loginScope = $rootScope.$new();

            $modal({
                template: 'partials/login.html',
                show: true,
                backdrop: 'static',
                persist: true,
                scope: $loginScope
            });
        };
    }])
    .controller('LoginController', [ '$scope', '$rootScope', '$modal', function ($scope, $rootScope, $modal) {
        $scope.loginWithLinkedIn = function () {
            window.location.href = 'http://127.0.0.1:5555/user/auth/linkedin'
        };

        $scope.loginWithFacebook = function () {
            window.location.href = 'http://127.0.0.1:5555/user/auth/facebook'
        };

        $scope.loginWithGoogle = function () {
            window.location.href = 'http://127.0.0.1:5555/user/auth/google_oauth2'
        }
    }]);