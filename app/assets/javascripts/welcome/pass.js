/* global m , Credentials , Modal $ */
var ModalRedeemContent = (function() {

    var merchant = {};
    var pass = {};

    var setMerchant = function(_merchant) {
        merchant = _merchant;
    };
    
    var setPass = function(_pass) {
        pass = _pass;
    };

    var cancelCode = function() {
        
    };
    
    
    var getCode = function() {
        m.request({
            url: "/api/redemption/get_code",
            method: "POST",
            body: {authorization: Credentials.getToken(), 
                   data: {merchant_id: merchant.id, pass_sn: pass.serialNumber}}
        }).then(function(data) {
            Modal.setBody("<div class=\"text-center\">Show this code to your server</div><h3 class=\"text-center\">"+data.code+"</h3>");
            Modal.setCancelButton("Cancel", cancelCode);
        }).catch(function(error) {
            Modal.setBody("Sorry, there was a problem. Please try again.");
            Modal.setCancelButton("OK");
        });
    };
    
    var view = function() {
        return m(".text-center", [m(".btn .btn-primary", {onclick: getCode}, "Request Code"),
            m(".small", "If not redeemed within 10 minutes, you can try again later.")]);
    };
    
    return {view: view, setMerchant: setMerchant, setPass: setPass};
})();

var PassComponent = (function() {
    
    var pass;
    var merchants = [];
    
    var oninit = function() {
        var pass_sn = document.location.pathname.split("/").pop();
        m.request({
            method: "POST",
            url: "/api/pass/"+pass_sn,
            body: {authorization: Credentials.getToken()}
        }).then(function(data) {
            pass = data;
            loadMerchants(pass.buyable);
        }).catch(function(error) {
            if (error.code === 401) {
                $(".placeholder").html("Not Logged In");
            }
        });
    };
    
    var loadMerchants = function(product) {
        var product_id = product.id;
        return m.request({
            method: "POST",
            url: "/api/merchants", 
            body: {query: {product_id: product_id}}
        }).then(function(data) {
            merchants = data;
        }).catch(function(e) {
            console.log(e);
        });
    };
    
    
    var redeem = function(event) {
        var merch_id = $(event.target).parent(".merchant").data("merchant-id");
        var merchant = merchants.find(function(merch) {return merch.id === merch_id});
        ModalRedeemContent.setMerchant(merchant);
        ModalRedeemContent.setPass(pass);
        Modal.setTitle("Redeem Pass at " + merchant.name);
        Modal.setBody(ModalRedeemContent);
        Modal.setCancelButton("Not Now");
        Modal.setOkButton(null);
        Modal.show();
    };
    
    var addLocation = function(merchant, loc) {
        return m("div.m-1.p-2.border.merchant[data-merchant-id="+merchant.id+"]", {onclick: redeem}, [
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
        
        if (typeof pass === "undefined") {
            return m(".h3.text-center.placeholder", "Loading...");
        } else {
            var merchList = []
            if (merchants.length > 0) {
                merchList = merchants.map(function(m) {return addMerchant(m);});
            } 
            return [m(".product.float-left.mt-0", {style: "width: 75px; height: 75px"}, [
                        m(".product-icon", {class: pass.buyable.icon}),
                        ]),
                    m(".card-text.pass-from", "From " + pass.purchaser.name),
                    m(".card-text.pass-message", pass.message),
                    m(".card-text", "Good for a " + pass.buyable.name),
                    m(".container", [m(".mt-5.text-center", "Select A Merchant To Redeem"),
                                     m(".small.text-center", "Don't worry, you can change your mind"),
                                     merchList]),
                    ];
        }
    };
    
    return {view: view, oninit: oninit};
    
})();

var Pass = (function() {
    var mount = function() {
        m.mount($(".pass")[0], PassComponent);
    };
    return {mount: mount};
})();