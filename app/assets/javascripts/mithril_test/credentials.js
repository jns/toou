
var Credentials = (function() {
    
    var PHONE_NUMBER = "phone";
    var TOKEN = "token";
    
    var getAuthHeader = function() {
        return {"Authorization": "Bearer " + getToken()};
    }
    
    var setPhoneNumber = function(phone_number) {
        return localStorage.setItem(PHONE_NUMBER, phone_number);
    };
    
    var getPhoneNumber = function() {
        return localStorage.getItem(PHONE_NUMBER);
    }
    
    var setToken = function(token) {
        return localStorage.setItem(TOKEN, token);
    }
    
    var getToken = function() {
        return localStorage.getItem(TOKEN);
    }
    
    var hasToken = function() { 
        var token = getToken();
        return (typeof token !== "undefined" && token !== null)    
    }
    
    return {setToken: setToken, 
            getToken: getToken,
            setPhoneNumber: setPhoneNumber,
            getPhoneNumber: getPhoneNumber,
            hasToken: hasToken,
            getAuthHeader: getAuthHeader};
})()