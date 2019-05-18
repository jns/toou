
var OneTimePasscode = (function() {
    
    var passcode = null;
    var feedback = null;
    
    var authenticate = function() {
        var phone_number = Credentials.getPhoneNumber();
        return m.request({
            method: "POST",
            url: "api/authenticate",
            data: {phone_number: phone_number, pass_code: passcode},
        }).then(function(data) {
            Credentials.setToken(data["auth_token"]);
            Modal.dismiss();
        }).catch(function(e) {
            feedback =  JSON.parse(e.message).error;
            $(".feedback").addClass("invalid-feedback");
            $(".feedback").show();
        });
    }
    
    var view = function() {
        return m(".container .mt-3 .mx-auto", [
                m(".row.text-center", [
                    m(".col", "We emailed you a passcode")
                    ]),
                m(".row", [
                    m(".col.input-group", [
                        m("input.form-control.text-center[type=text][placeholder=Passcode]", {
                            value: passcode, 
                            oninput: function(e) { passcode = e.target.value; }
                            }),
                        m("a.btn.input-group-append.input-group-text", {onclick: authenticate}, "Submit"),
                        ]),
                    ]),
                m(".row.col.text-center", [
                    m(".feedback", feedback)
                    ]),
            ]);
    };
    
    return {view: view};
})();