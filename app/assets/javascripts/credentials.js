/* global localStorage */

var Credentials = (function() {
    
    var TOKEN = "token";
    
    // Data for active tooU customer
    var customerData = undefined;
    
    // Data for authenticated user
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
      return hasToken(TOKEN);  
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
    
    var isRedemptionDevice = function() {
        return hasToken("REDEMPTION_TOKEN");
    }
    
    var getMissingCustomerDataFields = function() {
        return new Promise(function(resolve, reject) {
            getCustomerData().then(function(data) {
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
    
    var getCustomerData = function() {
        return new Promise(function(resolve, reject) {
            if (typeof customerData == 'undefined') {
                fetch('/api/account', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({authorization: Credentials.getToken()})
                }).then(function(response) { 
                    if (response.status == 200) {
                        customerData = response.json();
                        resolve(userData);
                    } else {
                        resolve(undefined);
                    }
                }).catch(function(err) {
                    resolve(undefined);
                });
            } else {
                resolve(customerData);
            }
        });
    };
    
    var refreshCustomerData = function() {
        customerData = undefined;
        getCustomerData();
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
    
    var resetPassword = function(token, new_password) {
        return new Promise(function(resolve, reject) {
            m.request({url: "/api/user/password_reset", 
                       method: "POST", 
                       body: {token: token, new_password: new_password}
            }).then(function(data) {
                setToken(data["auth_token"]);
                Dispatcher.dispatch(Dispatcher.topics.SIGNIN, {});
                resolve();
            }).catch(function(err) {
                setToken(null);
                reject(err.response["error"]);
            }); 
        });
    };
    
    var createMerchantAccount = function(email, password) {
        return new Promise(function(resolve, reject) {
            m.request({
                method: "POST",
                url: "/api/user/create_merchant_account",
                body: {data: {email: email, password: password}},
            }).then(function(data) {
                setToken(data["auth_token"]);
                userData.email = data["email"]
                Dispatcher.dispatch(Dispatcher.topics.SIGNIN, {});
                resolve();
            }).catch(function(e) {
                setToken(null);
                reject(e.response["error"]);
            });
        });    
    };
    
    var authenticateUser = function(email, password) {
        return new Promise(function(resolve, reject) {
            m.request({
                method: "POST",
                url: "/api/user/authenticate",
                body: {data: {email: email, password: password}},
            }).then(function(data) {
                console.log(data);
                setToken(data["auth_token"]);
                userData = {email:  data["email"]};
                Dispatcher.dispatch(Dispatcher.topics.SIGNIN, {});
                resolve();
            }).catch(function(e) {
                console.log(e);
                setToken(null);
                reject(e.response["error"]);
            });
        });
    };
    
    var authenticateGoogleUser = function(token) {
        return m.request({
            method: "POST",
            url: "/api/user/authenticate",
            body: {gtoken: token},
        }).then(function(data) {
            setToken(data["auth_token"]);
            userData = {email:  data["email"]};
            Dispatcher.dispatch(Dispatcher.topics.SIGNIN, {});
        }).catch(function(e) {
            setToken(null);
        });
    };
    
    var getUserData = function() {
        return new Promise(function(resolve, reject) {
            if (typeof userData == 'undefined') {
                m.request({url: "/api/user", 
                    method: "POST", 
                    body: {authorization: Credentials.getToken("USER_TOKEN")}
                }).then(function(data) {
                    userData = data;
                    resolve(userData);
                }).catch(function(err) {
                    reject(err);
                })
            } else {
                resolve(userData);
            }         
        });
    };
    
    var getUserToken = function() {
        return getToken();    
    };
    
    var logoutUser = function() {
        Credentials.setToken(null);  // also log out customer accounts;
        userData = undefined;
        googleSignout();
        Dispatcher.dispatch(Dispatcher.topics.SIGNOUT, {});
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
            getCustomerData: getCustomerData,
            getUserData: getUserData,
            getMissingCustomerDataFields: getMissingCustomerDataFields,
            authenticate: authenticate,
            authenticateUser: authenticateUser,
            logoutUser: logoutUser,
            isUserLoggedIn: isUserLoggedIn,
            isRedemptionDevice: isRedemptionDevice,
            getUserToken: getUserToken,
            resetPassword: resetPassword,
            createMerchantAccount: createMerchantAccount,
    };
})();