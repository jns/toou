/* global m, $, Credentials, Modal, OneTimePasscode, CreateAccount */

var Login = (function() {
    
    var phone_number = null;
    var feedback = null;
    
    
    var oninit = function() {
        Modal.setOkButton("Ok", requestOTP);
        Modal.setCancelButton("Not Now", Routes.goHome);
    };
    
    var requestOTP = function() {
        return m.request({
            method: "POST",
            url: "api/requestOneTimePasscode",
            body: {phone_number: phone_number},
        }).then(function(data) {
            Modal.setTitle("Thanks for coming!")
            Modal.setBody(OneTimePasscode);
        }).catch(function(e) {
            feedback = e.response["error"] + ", please try again.";
            $(".feedback").addClass("invalid-feedback");
            $(".feedback").show();
        });
    };
    
    
    var view = function() {
        return m(".container-fluid.mt-3.mx-auto", [
                m(".row", [
                    m(".col-sm.m-1.text-center", [
                        m("label.label[for=phone_number]", "We need your phone number to lookup your passes.")
                        ]),
                    ]),
                m(".row", [
                    m(".col-sm.input-group", [
                        m("input.form-control.text-center[name=phone_number][type=tel][placeholder=10 digit phone number]", {
                            value: phone_number, 
                            oninput: function(e) { phone_number = e.target.value;  },
                            onkeyup: function(e) { if (e.key === "Enter") { requestOTP(); } }
                            }),
                        // m("a.btn.input-group-append.input-group-text", {onclick: requestOTP}, [
                        //     "Send",
                        //     m("i.fas.fa-angle-right")
                        //     ]),
                        ]),
                    ]),
                m(".row.col.text-center", [
                    m(".feedback", feedback)
                    ]),
            ]);
    };
    
    return {view: view, oninit: oninit};
})();