/* global m, Credentials, Modal, $ */
var CreateAccount = (function() {
    
    var missing_fields = ["name", "email"];
    var name = undefined;
    var email = undefined;
    var feedback = null;
    
    var oninit = function() {
        Modal.setOkButton("Update Profile", update);
        Modal.setCancelButton("Not Now", dismiss);
    };
    
    var dismiss = function() {
        Modal.dismiss();
    };
    
    var update = function() {
        var data = {};
        if (name != undefined) {
            data["name"] = name;
        }
        if (email != undefined) {
            data["email"] = email;
        }
        return m.request({
            method: "PATCH",
            url: "api/account",
            body: {authorization: Credentials.getToken(), data: data},
        }).then(function(data) {
            dismiss();
            Credentials.refreshUserData();
        }).catch(function(e) {
            feedback =  e.response;
            $(".feedback").addClass("invalid-feedback");
            $(".feedback").show();
        });
    }
    
    var nameField = m(".row", [
                    m(".col.input-group", [
                        m("input.form-control.text-center.m-3[type=text][placeholder=Enter Your Name]", {
                            value: name, 
                            oninput: function(e) { name = e.target.value; }
                            }),
                        ]),
                    ]);
                    
    var emailField = m(".row", [
                    m(".col.input-group", [
                        m("input.form-control.text-center.m-3[type=email][placeholder=Enter Your Email]", {
                            value: email, 
                            oninput: function(e) { email = e.target.value; }
                            }),
                        ]),
                    ]);
                    
    var setMissing = function(values) {
        missing_fields = values;    
    };
    
    var view = function() {
        
        var rows = [
                m(".row.text-center", [
                    m(".col", "Please complete your profile.")
                    ]),
                m(".row.col.text-center", [
                    m(".feedback", feedback)
                    ]),
            ];
        if (missing_fields.indexOf("name") > -1) {
            rows.splice(1,1,nameField);
        }
        if (missing_fields.indexOf("email") > -1) {
            rows.splice(2,1,emailField);
        }
        return m(".container .mt-3 .mx-auto", rows);
    };
    
    return {view: view, oninit: oninit, setMissing: setMissing};
})();