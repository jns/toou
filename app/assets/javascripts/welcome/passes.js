/* global m, $, Credentials */
var PassesComponent = (function() { 
    
    var passList = []
    
    var contents = m(".text-center.h4", "Sorry, You don't have any passes.");
        
    var oninit = function() {
        contents = m(".text-center.h4", "Loading Passes...");
        return m.request({
            method: "POST",
            url: "api/passes",
            data: {},
            headers: Credentials.getAuthHeader(),
        }).then(function(data) {
            passList = data;
            if (passList.length === 0) {
                contents =  m(".text-center.h4", "Sorry, You don't have any passes.");
            }
        }).catch(function(e) {
            Modal.setTitle("Please Login To Access Your Passes");
            Modal.setBody(Login);
            Modal.setDismissalButton("Not Now");
            Modal.show(oninit);
        });
    };
    
    var addPassCard = function(pass) { 
        return m(".card.pass", {key: pass.serialNumber}, [
                m(".card-body.card-text",[
                    m(".pass-from", "From " + pass.purchaser.phone_number),
                    m(".pass-message", pass.message),
                    ])
            ]);
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