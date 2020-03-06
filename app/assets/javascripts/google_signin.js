/* global gapi, m, $ */

    
var GoogleSignin = (function() {
    
    var destination = ""
    
    var routeTo = function() {
        if (destination != "") {
            m.route.set(destination);
        }
    }
    
    var oninit = function() {
        Dispatcher.register(Dispatcher.topics.SIGNIN, routeTo);
    }

    var oncreate = function() {
        gapi.signin2.render('g-signin2', {
            'scope': 'profile email',
            'longtitle': true,
            'theme': 'dark',
            'margin': 'auto',
        }); 
    }
    
    var view = function(vnode) {
        destination = vnode.attrs.destination;
        return m(".w-100", [m(".m-1.text-center", "or"), m(".m-1", {id: "g-signin2"})]);  
    };
    
    return {view: view, oninit: oninit, oncreate: oncreate};
})();
