/* global m, $, Credentials, Modal, Routes, Login */
var PassesComponent = (function() { 
    
    var passList = [];
    var groupPasses = [];
    
    var contents = m(".text-center.h4", "Sorry, You don't have any passes.");
        
    var afterLogin = function() {
        Modal.dismiss();
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
        
        m.request({method: "POST", 
                    url: "/api/groups",
                    body: {authorization: Credentials.getToken()}
        }).then(function(data){
           groupPasses = data; 
        });
    };
    
    var oninit = function() {
        contents = m(".text-center.h4", "Loading Passes...");
        loadPasses();
    };
    
    var showGroupPass = function(ev) {
        var group_id = $(ev.target.closest(".pass")).data('pass-group-id');
        var buyable_id = $(ev.target).data('buyable-id');
        var buyable_type = $(ev.target).data('buyable-type');
        m.request({
            method: "POST",
            url: "/api/request_group_pass",
            body: {authorization: Credentials.getToken(), 
                    data: {group_id: group_id, buyable_id: buyable_id, buyable_type: buyable_type}}
        }).then(function(data) {
            var pass_sn = data.serialNumber;
            window.location.pathname = "/pass/"+pass_sn;
        }).catch(function(err) {
            alert(err);
        })
    };
    
    var showPass = function(ev) {
        var pass_sn = $(ev.target.closest(".pass")).data('pass-serial-number');
        window.location.pathname = "/pass/"+pass_sn;  
    };
    
    var passCardForGroup = function(group) {
        if (group.passes.length > 0) {
            var products = group.passes.map(function(p) {
                return m(".btn.btn-primary", {"data-buyable-id": p.buyable_id, "data-buyable-type": p.buyable_type, onclick: showGroupPass}, p.buyable_name + " " + p.pass_count + " available");
            });
            return m(".card.pass", {"data-pass-group-id": group.id}, [m(".card-header", group.name), m(".card-body.card-text", products)]);
        } else {
            return null;
        }
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
    
    var validPasses = function() {
        return passList.filter(function(p) {return p.status === "VALID"});
    };
    
    var usedPasses = function() {
        return passList.filter(function(p) {return p.status === "USED"});
    }
    
    var view = function() {
        var validContents, usedContents;
        var valid = validPasses();
        var used = usedPasses();

        
        validContents = groupPasses.map(function(g) {return passCardForGroup(g);});
        validContents.push(valid.map(function(p) {return addPassCard(p);}));
        
        if (validContents.length == 0) {
            validContents = m(".text-center.h4", "Sorry, You don't have any group passes.");
        }
        
        if (used.length > 0) {
            usedContents = used.map(function(p) {return addPassCard(p);});
        }
        return m(".container.accordian[id='PassAccordian']", [
                m(".card", [m(".card-header[id='ValidPassesHeading']", m(".h2.mb-0", m("button.btn.btn-link", {type: "button", "data-toggle": "collapse", "data-target": "#validPasses", "aria-expanded": "true", "aria-controls": "validPasses"}, "Valid Passes"))),
                            m(".collpase.show", {id: "validPasses", "aria-labelledby": "ValidPassesHeading", "data-parent": "#PassAccordian"}, m(".pass-container", validContents)),
                            ]),
                m(".card", [m(".card-header[id='UsedPassesHeading']", m(".h2.mb-0", m("button.btn.btn-link", {type: "button", "data-toggle": "collapse", "data-target": "#usedPasses", "aria-expanded": "false", "aria-controls": "usedPasses"}, "Used Passes"))),
                            m(".collpase", {id: "usedPasses", "aria-labelledby": "UsedPassesHeading", "data-parent": "#PassAccordian"}, m(".pass-container", usedContents)),
                            ]),
            ]);
    };
    
    return {view: view, oninit: oninit};
})();

var Passes = (function() {
    var mount = function() {
        m.mount($(".pass-list")[0], PassesComponent);
    }
    return {mount: mount};
})();