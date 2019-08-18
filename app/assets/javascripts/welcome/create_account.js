/* global m, Credentials, Modal, $ */
var CreateAccount = (function() {
    
    var name = null;
    var email = null;
    var feedback = null;
    
    var oninit = function() {
        Modal.setOkButton("Submit", update);
    }
    
    var update = function() {
        return m.request({
            method: "PATCH",
            url: "api/account",
            body: {authorization: Credentials.getToken(), data: {name: name, email: email}},
        }).then(function(data) {
            Credentials.setToken(data["auth_token"]);
            Modal.dismiss();
        }).catch(function(e) {
            feedback =  e.response["error"] + ". Please try again.";
            $(".feedback").addClass("invalid-feedback");
            $(".feedback").show();
        });
    }
    
    var view = function() {
        return m(".container .mt-3 .mx-auto", [
                m(".row.text-center", [
                    m(".col", "We just need your name and email.")
                    ]),
                m(".row", [
                    m(".col.input-group", [
                        m("input.form-control.text-center.m-3[type=text][placeholder=Enter Your Name]", {
                            value: name, 
                            oninput: function(e) { name = e.target.value; }
                            }),
                        ]),
                    ]),
                m(".row", [
                    m(".col.input-group", [
                        m("input.form-control.text-center.m-3[type=email][placeholder=Enter Your Email]", {
                            value: email, 
                            oninput: function(e) { email = e.target.value; }
                            }),
                        ]),
                    ]),
                m(".row.col.text-center", [
                    m(".feedback", feedback)
                    ]),
            ]);
    };
    
    return {view: view, oninit: oninit};
})();