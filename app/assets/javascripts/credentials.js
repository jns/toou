/* global localStorage */

var Credentials = (function() {
    
    var TOKEN = "token";
    
    var userData = undefined;
    
    var phone_number = undefined;
    var passcode = undefined;
    
    
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
    
    return {setToken: setToken, 
            getToken: getToken,
            phone_number: phone_number,
            passcode: passcode,
            hasToken: hasToken,
            getUserData: getUserData,
            getMissingUserDataFields: getMissingUserDataFields,
            authenticate: authenticate,
    };
})();