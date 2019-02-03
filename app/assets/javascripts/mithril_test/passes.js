/* global m, Credentials */
var Passes = (function() { 
    
    var passList = []
    
    var contents = "No Passes";
        
    var oninit = function() {
        Breadcrumb.home();
        contents = "Loading Passes";
        return m.request({
            method: "POST",
            url: "api/passes",
            data: {},
            headers: Credentials.getAuthHeader(),
        }).then(function(data) {
            passList = data;
        }).catch(function(e) {
            m.route.set("/login");
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