/* global localStorage */

var Credentials = (function() {
    
    var TOKEN = "token";
    
    var userData = undefined;
    
    var phone_number = undefined;
    var passcode = undefined;
    var auth2; // The Google Sign-In object.
    var googleUser; // The current user.

    var init = function() {
        gapi.load('auth2', initSigninV2);
    };

    /**
     * Initializes Signin v2 and sets up listeners.
     */
    var initSigninV2 = function() {

        auth2 = gapi.auth2.init({
          client_id: window.gapiCredentials.googleSigninClientId,
          scope: 'profile email'
        });
        
        // Listen for sign-in state changes.
        auth2.isSignedIn.listen(signinChanged);
    
        // Listen for changes to current user.
        auth2.currentUser.listen(userChanged);
    
        // Sign in the user if they are currently signed in.
        if (auth2.isSignedIn.get() == true) {
            auth2.signIn();
            googleUser = auth2.currentUser.get();
            authenticateGoogleUser(googleUser.getAuthResponse().id_token);
        }
    
    };


    /**
    * Listener method for sign-out live value.
    *
    * @param {boolean} state the updated signed out state.
    */
    var signinChanged = function (state) {
        if (state) {
            authenticateGoogleUser(googleUser.getAuthResponse().id_token);
        } else {
            logoutUser();
        }
    };


    /**
    * Listener method for when the user changes.
    *
    * @param {GoogleUser} user the updated user.
    */
    var userChanged = function (user) {
        googleUser = user;
    };

    var isUserLoggedIn = function() {
      return hasToken("USER_TOKEN");  
    };
    
    var setToken = function(arg1, arg2) {
        var token, token_name;
        if (arguments.length == 2) {
            token_name = arg1;
            token = arg2;
        } else {
            token_name = TOKEN;
            token = arg1;
        }
        
        if (typeof token === "undefined" || token === null) {
            userData = undefined;
            return localStorage.removeItem(token_name);
        } else {
            return localStorage.setItem(token_name, token);
        }
    };
    
    var getToken = function(name) {
        if (typeof name == 'undefined') {
            name = TOKEN;
        }
        return localStorage.getItem(name);
    };
    
    var hasToken = function(name) {
        if (typeof name == 'undefined') {
            name = TOKEN;
        }
        var token = getToken(name);
        return (typeof token !== "undefined" && token !== null);  
    };
    
    var getMissingUserDataFields = function() {
        return new Promise(function(resolve, reject) {
            getUserData().then(function(data) {
                if (data == undefined) {
                    resolve(["name", "email"]);
                } else {
                    var missingFields = [];
                    if (data["name"] == undefined) {
                        missingFields.push("name");
                    }
                    if (data["email"] == undefined) {
                        missingFields.push("email");
                    }
                    resolve(missingFields);
                }
            }).catch(function(err) {
                reject(err);
            }) 
        });
    };
    
    var getUserData = function() {
        return new Promise(function(resolve, reject) {
            if (typeof userData == 'undefined') {
                fetch('/api/account', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({authorization: Credentials.getToken()})
                }).then(function(response) { 
                    if (response.status == 200) {
                        userData = response.json();
                        resolve(userData);
                    } else {
                        resolve(undefined);
                    }
                }).catch(function(err) {
                    resolve(undefined);
                });
            } else {
                resolve(userData);
            }
        });
    };
    
    var refreshUserData = function() {
        userData = undefined;
        getUserData();
    };
    
    var authenticate = function(phone_number, passcode) {
        return m.request({
            method: "POST",
            url: "api/authenticate",
            body: {phone_number: phone_number, pass_code: passcode},
        }).then(function(data) {
            setToken(data["auth_token"]);
        }).catch(function(e) {
            setToken(null);
        });
    };
    
    var authenticateUser = function(username, password) {
        return new Promise(function(resolve, reject) {
            m.request({
                method: "POST",
                url: "/api/user/authenticate",
                body: {data: {username: username, password: password}},
            }).then(function(data) {
                setToken("USER_TOKEN", data["auth_token"]);
                resolve();
            }).catch(function(e) {
                setToken("USER_TOKEN", null);
                reject(e);
            });
        });
    };
    
    var authenticateGoogleUser = function(token) {
        return m.request({
            method: "POST",
            url: "/api/user/authenticate",
            body: {gtoken: token},
        }).then(function(data) {
            setToken("USER_TOKEN", data["auth_token"]);
        }).catch(function(e) {
            setToken("USER_TOKEN", null);
        });
    };
    
    var getUserToken = function() {
        return getToken("USER_TOKEN");    
    };
    
    var logoutUser = function() {
        Credentials.setToken("USER_TOKEN", null);
        googleSignout();
    };
    
    var googleSignout = function() {
        if (auth2.isSignedIn.get()) {
            auth2.signOut();  
        }
    };
    
    return {init: init,
            setToken: setToken, 
            getToken: getToken,
            phone_number: phone_number,
            passcode: passcode,
            hasToken: hasToken,
            getUserData: getUserData,
            getMissingUserDataFields: getMissingUserDataFields,
            authenticate: authenticate,
            authenticateUser: authenticateUser,
            logoutUser: logoutUser,
            isUserLoggedIn: isUserLoggedIn,
            getUserToken: getUserToken,
    };
})();