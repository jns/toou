var GoogleApi = (function() {
    
    var auth2;
    var pending = false;
    var listeners = [];
    
    var initSigin = function() {
        auth2 = gapi.auth2.init({
          client_id: window.gapiCredentials.googleSigninClientId,
          scope: 'profile email'
        });
        listeners.forEach(function(l) {l.call(auth2);});
        pending = false;
    }
    
    var onload = function() {
        return new Promise(function(resolve, reject) {
            if (auth2) {
                resolve(auth2);
            } else if (pending) {
                listeners.push(resolve);
            } else {
                pending = true;
                gapi.load('auth2', initSigin);
            }
        });
    }
    
    return {onload: onload};
})();