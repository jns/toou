/* global localStorage */

var Credentials = (function() {
    
    var TOKEN = "token";
    
    var userData = undefined;
    
    var phone_number = undefined;
    var passcode = undefined;
    
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
        return m.request({
            method: "POST",
            url: "/api/user/authenticate",
            body: {data: {username: username, password: password}},
        }).then(function(data) {
            setToken("USER_TOKEN", data["auth_token"]);
        }).catch(function(e) {
            setToken("USER_TOKEN", null);
        });
    };
    
    var authenticateGoogleUser = function(token) {
        return m.request({
            method: "POST",
            url: "/api/user/authenticate",
            body: {gtoken: token},
        }).then(function(data) {
            setToken("USER_TOKEN", data["auth_token"]);
            Dispatcher.dispatch(Dispatcher.topics.SIGNIN, {});
        }).catch(function(e) {
            setToken("USER_TOKEN", null);
            Dispatcher.dispatch(Dispatcher.topics.SIGNOUT, {});
        });
    };
    
    var getUserToken = function() {
        return getToken("USER_TOKEN");    
    };
    
    var logoutUser = function() {
        Credentials.setToken("USER_TOKEN", null);    
        Dispatcher.dispatch(Dispatcher.topics.SIGNOUT, {});
    };
    
    return {setToken: setToken, 
            getToken: getToken,
            phone_number: phone_number,
            passcode: passcode,
            hasToken: hasToken,
            getUserData: getUserData,
            getMissingUserDataFields: getMissingUserDataFields,
            authenticate: authenticate,
            authenticateUser: authenticateUser,
            authenticateGoogleUser: authenticateGoogleUser,
            logoutUser: logoutUser,
            isUserLoggedIn: isUserLoggedIn,
            getUserToken: getUserToken,
    };
})();