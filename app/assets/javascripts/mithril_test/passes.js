/* global m, Credentials */
var Passes = (function() { 
    
    var passList = []
    
    var fetchPasses = function() {
        return m.request({
            method: "POST",
            url: "api/passes",
            data: {},
            headers: Credentials.getAuthHeader(),
        }).then(function(data) {
            console.log(data);
            passList = data;
        }).catch(function(e) {
            console.log(e.message);
        });
    };
    
    var addPassCard = function(pass) { 
        console.log(pass);
        return m(".card.pass", [
                m(".card-body.card-text",[
                    m(".pass-from", "From " + pass.purchaser.phone_number),
                    m(".pass-message", pass.message),
                    ])
            ]);
    };
    
    var view = function() {
        var contents = "No Passes";
        if (passList.length > 0) {
            contents = passList.map(function(p) {return addPassCard(p);});
        }
        return m(".container", contents);
    };
    
    return {view: view, oninit: fetchPasses};
})();