angular.module('leadFinder.login.controller', ['leadFinder.general.services'])
    .controller('MenuController', [ '$scope', '$rootScope', '$modal', 'Authentication', '$location', '$templateCache', 'Analytics', function ($scope, $rootScope, $modal, auth, $location, $cache, analytics) {

        $scope.loginInformationPresent = false;
        $scope.loggedIn = false;

        $rootScope.$on('user-status-retrieved', function (ev, user) {
            $scope.loginInformationPresent = true;
            $scope.loggedIn = user.authenticated && user.found;
        });

        $scope.login = function () {

            analytics.report('Login', 'Modal', 'Open');

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
                .success(function (data) {
                    $scope.loggedIn = false;
                    $cache.remove('/partials/order-form.html');
                    $location.path('/')

                    analytics.report('Login', 'Logout', data.email);
                })
        }
    }])
    .controller('LoginController', [ '$scope', '$rootScope', '$modal', 'apiUrl', 'Analytics', function ($scope, $rootScope, $modal, apiUrl, analytics) {
        function redirect(service) {
            $scope.redirecting = true;
            analytics.report('Login', 'Redirect', service);

            window.location.href = apiUrl + '/user/auth/' + service;
        }

        $scope.loginWithLinkedIn = function () {
            redirect('linkedin');
        };

        $scope.loginWithFacebook = function () {
            redirect('facebook');
        };

        $scope.loginWithGoogle = function () {
            redirect('google_oauth2');
            ;
        }
    }]);