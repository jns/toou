/* global gapi, m, $ */

    
var GoogleSignin = (function() {
    
    var auth2; // The Sign-In object.
    var googleUser; // The current user.


    /**
     * Calls startAuth after Sign in V2 finishes setting up.
     */
    var oninit = function() {
      gapi.load('auth2', initSigninV2);
    };

    var oncreate = function() {
        gapi.signin2.render('g-signin2', {
            'scope': 'profile email',
            'width': 200,
            'height': 30,
            'longtitle': true,
            'theme': 'dark',
            // 'onsuccess': onSuccess,
            // 'onfailure': onFailure
        });
    }

    /**
     * Initializes Signin v2 and sets up listeners.
     */
    var initSigninV2 = function() {
        auth2 = gapi.auth2.init({
          client_id: window.toouAssets.googleSigninClientId,
          scope: 'profile email'
        });
    
        // Listen for sign-in state changes.
        auth2.isSignedIn.listen(signinChanged);
    
        // Listen for changes to current user.
        auth2.currentUser.listen(userChanged);
    
        // Sign in the user if they are currently signed in.
        if (auth2.isSignedIn.get() == true) {
            auth2.signIn();
        }
    
        // Start with the current live values.
        refreshValues();
    };


    /**
    * Listener method for sign-out live value.
    *
    * @param {boolean} state the updated signed out state.
    */
    var signinChanged = function (state) {
        if (state) {
            Dispatcher.dispatch(Dispatcher.topics.SIGNIN, googleUser);
        } else {
            Dispatcher.dispatch(Dispatcher.topics.SIGNOUT, {});
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


    /**
    * Retrieves the current user and signed in states from the GoogleAuth
    * object.
    */
    var refreshValues = function() {
        if (auth2){
            googleUser = auth2.currentUser.get();
        }
    }
    
    var isSignedIn = function() {
        if (auth2) {
            return auth2.isSignedIn;
        } else {
            return false;
        }
    };
    
    var view = function(vnode) {
        if (! isSignedIn() ) {
            return m(".mx-auto", {id: "g-signin2"});  
        }
    };
    
    return {view: view, oninit: oninit, oncreate: oncreate, isSignedIn: isSignedIn};
})();
