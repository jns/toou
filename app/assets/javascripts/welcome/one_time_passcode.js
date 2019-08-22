/* global m, Credentials, Modal, CreateAccount $ */
var OneTimePasscode = (function() {
    
    var feedback = null;

    var oninit = function(vnode) {
    };
    
    var view = function() {
        return m(".container .mt-3 .mx-auto", [
                m(".row.text-center", [
                    m(".col", "We texted you a passcode")
                    ]),
                m(".row", [
                    m(".col.input-group", [
                        m("input.form-control.text-center[type=text][placeholder=Passcode]", {
                            value: Credentials.passcode, 
                            oninput: function(e) { Credentials.passcode = e.target.value; }
                            }),
                        // m("a.btn.input-group-append.input-group-text", {onclick: authenticate}, "Submit"),
                        ]),
                    ]),
                m(".row.col.text-center", [
                    m(".feedback", feedback)
                    ]),
            ]);
    };
    
    return {view: view, oninit: oninit};
})();