angular.module('leadFinder.login.controller', ['leadFinder.general.services'])
    .controller('MenuController', [ '$scope', '$rootScope', '$modal', 'Authentication', '$location', '$templateCache', function ($scope, $rootScope, $modal, auth, $location, $cache) {

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

        $scope.logout = function () {
            auth.logout()
                .success(function () {
                    $scope.loggedIn = false;
                    $cache.remove('/partials/order-form.html');
                    $location.path('/')
                })
        }
    }])
    .controller('LoginController', [ '$scope', '$rootScope', '$modal', function ($scope, $rootScope, $modal) {
        $scope.loginWithLinkedIn = function () {
            $scope.redirecting = true;
            window.location.href = 'http://127.0.0.1:5555/user/auth/linkedin'
        };

        $scope.loginWithFacebook = function () {
            $scope.redirecting = true;
            window.location.href = 'http://127.0.0.1:5555/user/auth/facebook'
        };

        $scope.loginWithGoogle = function () {
            $scope.redirecting = true;
            window.location.href = 'http://127.0.0.1:5555/user/auth/google_oauth2'
        }
    }]);