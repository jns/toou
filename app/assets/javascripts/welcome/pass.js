/* global m , $ */
var MerchantList = (function() {
    
    var merchants = [];
    var contents = m(".text-center.h4", "Sorry, There are no merchants that will redeem this pass.");
    
    var oninit = function() {
        var product_id = $(".pass").data('product-id');
        return m.request({
            method: "POST",
            url: "/api/merchants", 
            body: {query: {product_id: product_id}}
        }).then(function(data) {
            merchants = data;
            if (merchants.length === 0) {
                contents =  m(".text-center.h4", "Sorry, There are no merchants that will redeem this pass.");
            }
        }).catch(function(e) {
            console.log(e);
        });
    };
    
    var addLocation = function(merchant, loc) {
        return m("div.m-1.p-2.border", [
            m("div", merchant.name),
            m("div", loc.name),
            m("div", loc.address1),
            m("div", loc.address2),
            m("div", loc.city + ", " + loc.state + " " + loc.zip),
            ]);
    }
    var addMerchant = function(merchant) {
        var locations = merchant.locations.map(function(loc) {
            return addLocation(merchant, loc);
        })
        return m("div", locations);

    };
    
    var view = function() {
        if (merchants.length > 0) {
            contents = merchants.map(function(m) {return addMerchant(m);});
        }
        
        return m(".container",contents);
    };
    return {view: view, oninit: oninit};
});

var Pass = (function() {
    var mount = function() {
        $("#load-redeem-locations").click(function() { 
            $(".merchant-list").show();
        });
        $(".merchant-list").hide();
        m.mount($(".merchant-list")[0], MerchantList);
    };
    return {mount: mount};
})();