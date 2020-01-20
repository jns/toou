/* global gapi, m, $ */

    
var GoogleSignin = (function() {
    

    var oncreate = function() {
        gapi.signin2.render('g-signin2', {
            'scope': 'profile email',
            'longtitle': true,
            'theme': 'dark',
            'margin': 'auto',
        });
    }
    
    var view = function(vnode) {
        return m(".w-100", [m(".m-1.text-center", "or"), m(".m-1", {id: "g-signin2"})]);  
    };
    
    return {view: view, oncreate: oncreate};
})();
