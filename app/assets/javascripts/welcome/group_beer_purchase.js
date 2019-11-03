/* global $, m,  Payment, GroupBeerPurchase */

var GroupBeerPayment = (function() {
    
    var mount = function() {
        m.request({
            method: "GET",
            url: "/api/products",
        }).then(function(products) {
            var b = products.find(function(b) {
                return b["name"] === "Beer"; 
            });
            if (typeof b != 'undefined') {
                Payment.setBuyable(b);
            }
        }).catch(function(e) {
        });
        
        Payment.setRecipient({group: GroupBeerPurchase.group_id});
        
    };
    
    return {mount: mount};
})();