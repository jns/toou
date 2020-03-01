/* global m, $, GoogleSignin */
var MerchantNew = (function() {
    
    var mode = "init";
    var error = null;
    var successDestination = "/merchants/dashboard";
    
    var submit = function(ev) {
        ev.preventDefault();
        var email = $("#email").val();
        var password = $("#password").val();
        Credentials.createMerchantAccount(email, password)
        .then(function(data){
            mode = "done";
            m.route.set(successDestination);
        })
        .catch(function(e) {
           error = e; 
           mode = "error";
        });
        mode = "pending";
    }
    
    var view = function(vnode) {

        if (mode == "pending") {
            return m(".m-5.text-center", m("i.fas.fa-spinner"));
        } else {
            return m("form.content-width.mx-auto", 
            [m(".h5.text-center", "New Merchant Account"),
                m(".error.text-center", error),
                m(".form-group", [
                    m("label", {for: "email"}, "email"),
                    m("input.form-control", {type: "email", id: "email", name: "email"}),
                    ]),
                m(".form-group", [
                    m("label", {for: "password"}, "password"),
                    m("input.form-control", {type: "password", id: "password", name: "password"}),
                    ]),
                m(".text-center", m("input.btn.btn-primary", {type: "submit", onclick: submit, value: "Create Account"})),
                m(".text-center", m(GoogleSignin, {destination: successDestination})),
                ]);
        }
    }
    
    return {view: view};
})();