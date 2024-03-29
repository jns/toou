/* global m, Credentials, Modal, CreateAccount $ */
var OneTimePasscode = (function() {
    
    var passcode = null;
    var phone_number = null;
    
    var oninit = function(vnode) {
        phone_number = vnode.attrs.phone_number;
    };
    
    var getPasscode = function() {
        return passcode;
    };
    
    var getPhoneNumber = function() {
        return phone_number;
    };
    
    var passcodeAuthentication = function() {
        if (Credentials.authenticate(phone_number, passcode)) {
            return true;
        } else {
            throw "Invalid Credentials";
        }
    };
    
    var cancel = function() {
       return new Promise(function(resolve, reject) {
          m.route.set("/");
          resolve();
       });
    };
    
    var view = function(vnode) {
        return m(".container .mt-3 .mx-auto", [
                m(".row.text-center", [
                    m(".col", "Please enter the authentication code we texted to " + vnode.attrs.phone_number)
                    ]),
                m(".row", [
                    m(".col.input-group", [
                        m("input.form-control.text-center[type=text][placeholder=Passcode]", {
                            value: Credentials.passcode, 
                            oninput: function(e) { passcode = e.target.value; }
                            }),
                        // m("a.btn.input-group-append.input-group-text", {onclick: authenticate}, "Submit"),
                        ]),
                    ]),
                m(".row.col.text-center", [
                    m(".feedback", vnode ? vnode.attrs.feedback : "")
                    ]),
            ]);
    };
    
    return {view: view, oninit: oninit, okClicked: passcodeAuthentication, okText: "Submit", cancelText: "Not Now", cancelClicked: cancel};
})();