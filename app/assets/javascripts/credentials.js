/* global localStorage */

var Credentials = (function() {
    
    var PHONE_NUMBER = "phone";
    var TOKEN = "token";
    
    var setPhoneNumber = function(phone_number) {
        return localStorage.setItem(PHONE_NUMBER, phone_number);
    };
    
    var getPhoneNumber = function() {
        return localStorage.getItem(PHONE_NUMBER);
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
            return localStorage.removeItem(token_name);
        } else {
            return localStorage.setItem(token_name, token);
        }
    };
    
    var getToken = function(name = TOKEN) {
        return localStorage.getItem(name);
    };
    
    var hasToken = function(name = TOKEN) { 
        var token = getToken(name);
        return (typeof token !== "undefined" && token !== null);  
    };
    
    return {setToken: setToken, 
            getToken: getToken,
            setPhoneNumber: setPhoneNumber,
            getPhoneNumber: getPhoneNumber,
            hasToken: hasToken};
})();