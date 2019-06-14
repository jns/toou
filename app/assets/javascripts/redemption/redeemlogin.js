/* global m, $, Credentials, Routes */

var MerchantAutocomplete = (function() {
    
    var content = [];
    
    var oninit = function() {
        $('.merchant-name').keyup(search);
    };
    
    var authorize = function(ev) {
        var merch_id = $(ev.target).data("merchant-id");
        m.request({
            method: "POST",
            url: "/api/redemption/authorize_device",
            body: {"merchant_id": merch_id}
        }).then(function(data) {
            console.log(data);
            Credentials.setToken(data.auth_token);
            Routes.goRedeem();
        });
    };
    
    var addMerchant = function(merch) {
        merch.locations.forEach(function(loc) {
            var text = merch.name + " - " + loc.address1 + " - " + loc.city + ", " + loc.state; 
            content.push(m("li.list-group-item[data-merchant-id="+merch.id+"]", {onclick: authorize}, text));
        });
    };
    
    var search = function() {
        var text = $('.merchant-name').val();
        if (text.length < 3) {
            return;
        }
        
        m.request({
            method: "POST",
            body: {"query": {"name": text}},
            url: "/api/merchants"
        }).then(function(data) {
            content.length = 0;
            data.forEach(function(merch) {
                console.log(merch);
                addMerchant(merch);
            });
        });
    };
    
    
    var view = function() {
        return m("ul.list-group", content);
    };
    
    return {view: view, oninit: oninit};
})();

var RedeemLogin = (function() {
    
    var mount = function() {
        m.mount($(".merchant-autocomplete")[0], MerchantAutocomplete);
    }
    
    return {mount: mount}
})();