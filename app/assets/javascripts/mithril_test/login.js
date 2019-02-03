/* global m, Credentials */

var Login = (function() {
    
    var phone_number = null
    
    var requestOTP = function() {
        return m.request({
            method: "POST",
            url: "api/requestOneTimePasscode",
            data: {phone_number: phone_number},
        }).then(function(data) {
            Credentials.setPhoneNumber(phone_number);
            m.route.set("/otp");
        }).catch(function(e) {
            console.log(e.message);
        });
    };
    
    
    var view = function() {
        return m(".container-fluid .mt-3 .mx-auto", [
                m(".row.text-center", [
                    m(".col.m-1", [
                        m("label.label", "We need your phone number to lookup your passes.")
                        ])
                    ]),
                m(".row.text-center.no-gutters", [
                    m(".col-10", [
                        m("input.form-control.text-center[type=text][placeholder=10 digit phone number]", {
                            value: phone_number, 
                            oninput: function(e) { phone_number = e.target.value;  },
                            onkeyup: function(e) { if (e.key === "Enter") { requestOTP(); } }
                            })
                        ]),
                    m(".col-2", [
                        m("a.btn.btn-outline-dark", {onclick: requestOTP}, [
                            m("i.fas.fa-angle-right")
                            ]),
                        ]),
                    ])
            ])
    }
    
    return {view: view}
})();