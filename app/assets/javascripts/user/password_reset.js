/* global Credentials */
/**
 * Renders a password reset form if the user is authenticated. 
 * Renders a "Send email to reset password" form if user is not authenticated
 */
var PasswordReset = (function() {

    var mode = "start";
    var token = null;    
    var error = null;
    
    var resetPassword = function(ev) {
        ev.preventDefault();
        var new_password = $("#new_password").val();
        Credentials.resetPassword(token, new_password)
            .then(function() {
                mode = "done";
            }).catch(function(e) {
                error = e
                mode = "error";
            });
        mode = "pending";
    };
    
    var view = function(vnode) {
        
        token = vnode.attrs.token;

        if (mode == "done") {
            return m(".content-width.mx-auto", [m(".mt-5.text-center.h5", "Password successfully reset"), 
                    m(".mt-3.text-center", m(m.route.Link, {class: "mt-3 btn btn-link", href: "/merchants/dashboard"}, "Go To Dashboard")), 
                    ]);
        } else if (mode == "pending") {
            return m(".m-5.text-center", m("i.fas.fa-spinner"));
        } else if (mode == "error") {
            return m(".content-width.mx-auto", [m(".mt-5.text-center.h5", "There was a problem resetting your password"), 
                    m(".mt-3.text-center", m(m.route.Link, {class: "btn btn-warning", href: "/password_reset"}, "Try Again"))]);
        } else {
            return m("form.form-group.content-width.mx-auto", {onsubmit: resetPassword}, [
                m(".h5.mt-3.text-center", "Enter New Password"),
                m(".error.text-center", error),
                m("input.mt-3.form-control.text-center", {type: "password", id: "new_password", placeholder: "password"}),
                m(".mt-3.text-center", m("input.btn.btn-primary", {type: "submit", value: "Submit"})),
                ]);
        } 
    };
    
    return {view: view};
})();