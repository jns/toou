
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
    }
    
    
    var view = function() {
        return m(".container .mt-3 .mx-auto", [
                m(".row.text-center", [
                    m(".col-sm-10.m-1", [
                        m("input.form-control[type=text][placeholder=10 digit phone number]", {
                            value: phone_number, 
                            oninput: function(e) { phone_number = e.target.value; }
                            }),
                        ]),
                    m(".col-sm-2.m-1", [
                        m("input.btn.btn-primary[type=button]", {value:"Login", onclick: requestOTP}),
                        ]),
                    ])
            ])
    }
    
    return {view: view}
})();