/* global Credentials, m */
var MerchantBusinesses = (function() {
    
    var businesses = [];
    
    var oncreate = function(vnode) {
        m.request({url: "/api/merchant/merchants", 
                    method: "POST", 
                    body: {authorization: Credentials.getUserToken()}})
            .then(function(data) {
                businesses = data;
                console.log("Loaded " + businesses.length + " businesses");
            }).catch(function(err) {
                console.log(err);
            })
    };
    
    var tableRow = function(business) {
        return m("tr.tr", m("td.td", m(m.route.Link, {href: "/merchants/" + business.id}, business.name)));
    };
    
    var addBusiness = function() {
        m.route.set("/merchants/onboard");    
    };
    
    var view = function(vnode) {
        
        return m(".card", 
                  [m(".card-header", "Businesses"),
                   m(".card-body", [
                       m("table.table", m("tbody", businesses.map(function(b) { return tableRow(b); }))),
                       m(".text-center", m("button.btn.btn-primary", {onclick: addBusiness },"Add A Business")),
                       ]),
                   ]);
    }
    
    return {view: view, oncreate: oncreate};
})();