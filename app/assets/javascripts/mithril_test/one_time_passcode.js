
var OneTimePasscode = (function() {
    
    var passcode = null;
    
    var authenticate = function() {
        var phone_number = Credentials.getPhoneNumber();
        return m.request({
            method: "POST",
            url: "api/authenticate",
            data: {phone_number: phone_number, pass_code: passcode},
        }).then(function(data) {
            Credentials.setToken(data["auth_token"]);
            m.route.set("/passes");
        }).catch(function(e) {
            console.log(e.message);
        });
    }
    
    var view = function() {
        return m(".container .mt-3 .mx-auto", [
                m(".row.text-center", [
                    m(".col", "We just texted you a passocde")
                    ]),
                m(".row.text-center", [
                    m(".col-sm-10.m-1", [
                        m("input.form-control.text-center[type=text][placeholder=Passcode]", {
                            value: passcode, 
                            oninput: function(e) { passcode = e.target.value; }
                            }),
                        ]),
                    m(".col-sm-2.m-1", [
                        m("input.btn.btn-primary[type=button]", {value:"Login", onclick: authenticate}),
                        ]),
                    ])
            ])
    }
    
    return {view: view}
})();