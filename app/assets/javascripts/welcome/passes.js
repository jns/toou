/* global m, $, Credentials, Modal, Routes, Login */
var PassesComponent = (function() { 
    
    var passList = []
    
    var contents = m(".text-center.h4", "Sorry, You don't have any passes.");
        
    var afterLogin = function() {
        loadPasses();    
    };
    
    var loadPasses = function() {
        m.request({
            method: "POST",
            url: "api/passes",
            body: {authorization: Credentials.getToken()}
        }).then(function(data) {
            passList = data;
            if (passList.length === 0) {
                contents =  m(".text-center.h4", "Sorry, You don't have any passes.");
            }
            Credentials.getMissingUserDataFields().then(function(missing) {
                if (missing.length > 0) {
                    CreateAccount.setMissing(missing);
                    Modal.setTitle("Complete Your Profile");
                    Modal.setBody(CreateAccount);
                    Modal.show();
                }
            });
        }).catch(function(e) {
            if (e.code == 401) {
                Modal.setTitle("Please Login To Access Your Passes");
                Modal.setBody(Login);
                Modal.show(afterLogin);
            } else {
                Modal.setTitle("Sorry about this");
                Modal.setBody("There was a problem.  Please try again");
                Modal.setCancelButton(null);
                Modal.setOkButton("Ok", Modal.dismiss);
            }
        });        
    };
    
    var oninit = function() {
        contents = m(".text-center.h4", "Loading Passes...");
        loadPasses();
    };
    
    var showPass = function(ev) {
        var pass_sn = $(ev.target.closest(".pass")).data('pass-serial-number');
        window.location.pathname = "/pass/"+pass_sn;  
    };
    
    var addPassCard = function(pass) { 
        var cardBody = [
                    m(".pass-from", "From " + pass.purchaser.name + "(" + pass.purchaser.phone_number + ")"),
                    m(".pass-message", pass.message),
                    m(".pass-product", "Good for 1 (ONE) " + pass.buyable.name + " up to " + pass.value_dollars + " including tax and tip"),
            ];
            
        if (pass.status === "VALID") {
            cardBody.push(m(".text-center", [m(".btn.btn-primary.mt-2", {onclick: showPass}, "Redeem")]));
        } else {
            cardBody.push(m(".pass-status-"+pass.status, pass.status));
        }
        
        return m(".card.pass", {key: pass.serial_number, "data-pass-serial-number": pass.serialNumber }, [
                m(".card-body.card-text", cardBody)]);
    };
    
    var view = function() {
        if (passList.length > 0) {
            contents = passList.map(function(p) {return addPassCard(p);});
        }
        return m(".container", contents);
    };
    
    return {view: view, oninit: oninit};
})();

var Passes = (function() {
    var mount = function() {
        m.mount($(".pass-list")[0], PassesComponent);
    }
    return {mount: mount};
})();