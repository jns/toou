/* global m, $, Credentials, Modal, Routes, Login */
var PassesComponent = (function() { 
    
    var passList = []
    
    var contents = m(".text-center.h4", "Sorry, You don't have any passes.");
        
    var oninit = function() {
        contents = m(".text-center.h4", "Loading Passes...");
        return m.request({
            method: "POST",
            url: "api/passes",
            body: {authorization: Credentials.getToken()}
        }).then(function(data) {
            passList = data;
            if (passList.length === 0) {
                contents =  m(".text-center.h4", "Sorry, You don't have any passes.");
            }
        }).catch(function(e) {
            Modal.setTitle("Please Login To Access Your Passes");
            Modal.setBody(Login);
            Modal.setOkButton(null);
            Modal.setCancelButton("Not Now", Routes.goHome);
            Modal.show(oninit);
        });
    };
    
    var showPass = function(ev) {
        var pass_sn = $(ev.target.closest(".pass")).data('pass-serial-number');
        window.location.pathname = "/pass/"+pass_sn;  
    };
    
    var addPassCard = function(pass) { 
        var cardBody = [
                    m(".pass-product", "Good for one " + pass.buyable.name),
                    m(".pass-from", "From " + pass.purchaser.name + "(" + pass.purchaser.phone_number + ")"),
                    m(".pass-message", pass.message),
            ];
            
        if (pass.status === "VALID") {
            cardBody.push(m(".pass-expiration", "Expires on "+ pass.expires_on));
            cardBody.push(m(".btn .btn-primary", {onclick: showPass}, "Redeem"));
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