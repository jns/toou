/* global m, $, Credentials */
/**
 * Renders a password reset form if the user is authenticated. 
 * Renders a "Send email to reset password" form if user is not authenticated
 */
var PasswordResetRequest = (function() {
    
    var message = "";
    var mode = "initial";
    
    var requestReset = function(ev) {
        ev.preventDefault();
        
        var email = $("#password_reset_email").val();
        m.request({url: "/api/user/request_password_reset",
                  method: "POST", 
                  body: {email: email}
        }).then(function(data){
            mode = "done";   
        }).catch(function(err) {
            mode = "error";
            message = err.error;
        });
        
        mode = "loading";
        
        
    }
    
    var view = function(vnode) {
        if (mode == "loading") {
            return m(".m-5.text-center", m("i.fas.fa-spinner"));
        } else if (mode == "done") {
            return m(".m-5.text-center", "Please check your email for a password reset email from TooU");
        } else if (mode == "error") {
            return m(".m-5.mtext-center", message);
        } else {
            return m("form.form-group.content-width.mx-auto", {onsubmit: requestReset}, 
            [m(".h5.mt-3.text-center", "Please provide your email to reset your password"),
                m("input.mt-3.form-control.text-center", {id: "password_reset_email", type: "text", placeholder: "email"}),
                m(".mt-3.text-center", m("input.btn.btn-primary", {type: "submit", value: "Reset Password"})),
            ]);
        }
    
    };
    
    return {view: view};
})();