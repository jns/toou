/* global m, $, Credentials */
var MerchantLogin = (function() {
    
    var destination = "";
    var error = "";
    
    var submit = function(ev) {
        ev.preventDefault();
        var email = $("input[name=username").val();
        var password = $("input[name=password").val();
        Credentials.authenticateUser(email, password).then(function() {
            m.route.set(destination);
        }).catch(function(e) {
            error = e;
        });
    };
    
    var view = function(vnode) {
        destination = m.route.get();
        return m("form.content-width.container", [
            m(".row", m(".col.error.text-center", error)),
            m(".row", m(".col", m(".form-group", [
                m("label", {for: "email"}, "email"),
                m("input.form-control", {type: "email", name: "email"}),
                ]))),
            m(".row", m(".col", m(".form-group", [
                m("label", {for: "password"}, "password"),
                m("input.form-control", {type: "password", name: "password"}),
                ]))),
            m(".row", m(".col.text-center", 
                 [m("input.btn.btn-primary", {type: "submit", onclick: submit, value: "Sign in"}),
                 m(m.route.Link, {href: "/password_reset", class: "btn btn-link"}, "Forgot Password")])),
            m(".row.justify-content-center", m(".col", m(GoogleSignin, {destination: destination}))),
            ]);
    };
    
    return {view: view}
})();