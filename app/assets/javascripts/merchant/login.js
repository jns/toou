/* global m, $ */
var Login = (function() {
    
    var submit = function() {
        var csrfToken = document.querySelector('meta[name=csrf-token]').getAttribute('content');
        var username = $("input[name=username").val();
        var password = $("input[name=password").val();
        
        var body = {username: username, password: password};
        console.log(body);
    };
    
    var view = function(vnode) {
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
                m("input.btn.btn-primary", {type: "button", onclick: submit, value: "Create Account"}))),
            m(".row.justify-content-center", m(".col", m(GoogleSignin))),
            ]);
    };
    
    return {view: view}
})();