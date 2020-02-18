/* global m, $, Credentials */
var MerchantLogin = (function() {
    
    var destination = "";
    
    var submit = function() {
        var username = $("input[name=username").val();
        var password = $("input[name=password").val();
        Credentials.authenticateUser(username, password).then(function() {
            m.route.set(destination);
        });
    };
    
    var view = function(vnode) {
        destination = m.route.get();
        return m(".content-width.container", [
            m(".row", m(".col", m(".form-group", [
                m("label", {for: "username"}, "email"),
                m("input.form-control", {type: "email", name: "username"}),
                ]))),
            m(".row", m(".col", m(".form-group", [
                m("label", {for: "password"}, "password"),
                m("input.form-control", {type: "password", name: "password"}),
                ]))),
            m(".row", m(".col.text-center", 
                m("input.btn.btn-primary", {type: "button", onclick: submit, value: "Sign in"}))),
            m(".row.justify-content-center", m(".col", m(GoogleSignin, {destination: destination}))),
            ]);
    };
    
    return {view: view}
})();