/* global m, $, Breadcrumb */

var MerchantProducts = (function() {
    
    var products = [];
    
    var oninit = function() {

    };
    
    var product_row = function(p) {
        return m("tr", [
                    m("td.text-center", m("input.form-check-input[type=checkbox]", {checked: p["can_redeem"]})),
                    m("td.text-left", p.name),
                    m("td", p.price_formatted),
                    ]);
    };
    
    var view = function() {
        
        var thead = m("thead", [
            m("th", {width: 10}, "Redeem?"),
            m("th.text-left", "Product"),
            m("th", "Price")]);
        
        var trows = [];
        products.forEach(function(p) {
            trows.push(product_row(p));
        });
        
        var tbody = m("tbody", trows);

        return m("table.table", [thead, tbody]);
    };

    
    return {view: view};
})();

var Merchants = (function() {

    var client_id;
    
    $.get("/keys/stripe_client_id", function(data) {
        client_id = data["stripe_client_id"];
    });

    var stripeConnect = function(event) {
        var stripe_connect_url;
        var merchant_id = $(event.currentTarget).data('merchant-id');
        if (typeof merchant_id != undefined && merchant_id !== null) {
            stripe_connect_url = "https://connect.stripe.com/express/oauth/authorize";
            stripe_connect_url += "?redirect_uri=https://" + window.location.host + "/merchants/enroll";
            stripe_connect_url += "&client_id=" + client_id;
            stripe_connect_url += "&state="+merchant_id;
            window.location = stripe_connect_url;
        }
    };
    
    var stripeDashboard = function(event) {
        var merchant_id = $(event.currentTarget).data('merchant-id');
        if (typeof merchant_id != undefined && merchant_id !== null) {
            $.get("/merchants/"+merchant_id+"/stripe_dashboard_link",function(data) {
                window.location = data.url;
            });
        }
    };    
    
    var enableProductSave = function(event) {
        $('.merchant-products-submit').fadeIn(500);
        var t = $(event.target);
        console.log(t.val());
    };
    
    var saveProducts = function() {
        
    }
    
    var mount = function() {
        $('.stripe-connect').click(stripeConnect);
        $('.stripe-dashboard-link').click(stripeDashboard);
        $('.product-redeem-checkbox').click(enableProductSave);
    };
    
    return {mount: mount};
})();
