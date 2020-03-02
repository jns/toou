/* global Credentials, m */
var MerchantBusinesses = (function() {
    
    var businesses = [];
    var mode = "loading";
    
    var oncreate = function(vnode) {
        m.request({url: "/api/merchant/merchants", 
                    method: "POST", 
                    body: {authorization: Credentials.getUserToken()}})
            .then(function(data) {
                mode = "done";
                businesses = data;
            }).catch(function(err) {
                console.log(err);
            })
        mode = "loading"
    };
    
    var tableRow = function(business) {
        return m("tr.tr", m("td.td", m(m.route.Link, {href: "/merchants/" + business.id}, business.name)));
    };
    
    var addBusiness = function() {
        m.route.set("/merchants/onboard");    
    };
    
    var view = function(vnode) {
        
        if (mode == "loading") {
            return m(".m-5.text-center", m("i.fas.fa-spinner"));
        } else if (businesses.length > 0) {
            return m(".card", 
                      [m(".card-header", "Businesses"),
                       m(".card-body", [
                           m("table.table", m("tbody", businesses.map(function(b) { return tableRow(b); }))),
                           m(".text-center", m("button.btn.btn-primary", {onclick: addBusiness },"Add A Business")),
                           ]),
                       ]);
        } else {
            return m(".m-5.text-center", m("button.btn.btn-primary", {onclick: addBusiness },"Onboard Your Business"));
        }
    }
    
    return {view: view, oncreate: oncreate};
})();