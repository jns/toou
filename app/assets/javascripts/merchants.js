/* global m, $, Breadcrumb, Credentials */

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
    
    $.get("/merchants/token")
        .done(function(data) {
           var token = data["auth_token"];
            Credentials.setToken(token);
        })
        .fail(function() {
           Credentials.setToken(); 
        });

    var stripeConnect = function(event) {
        var stripe_connect_url;
        var merchant_id = $(event.currentTarget).data('merchant-id');
        // m.request({
        //     method: "POST",
        //     url: "",
        //     body: {authorization: Credentials.getToken(),
        //             data: {merchant_id: merchant_id}}
        // }).then(function(data){
        //     console.log(data);
        // }).catch(function(error){
        //     console.log(error);
        // });
        
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
            }).fail(function() {
                $(".stripe-dashboard-link").html("Error connecting to Stripe");
            });
        }
    };    
    
    var enableProductSave = function(event) {
        $('.merchant-products-submit').fadeIn(500);
    };
    
    var submitAuthDevice = function() {
        var device_id = $('.authorize-device-link input[type="text"').val();
        var merchant_id = $('.merchant-data').data('merchant-id');
        $.post("/api/merchant/authorize_device", {
            authorization: Credentials.getToken(),
            data: {merchant_id: merchant_id, device_id: device_id}
        })
        .done(function(data) {
            console.log(data["auth_token"]);
            // window.location.reload();
        })
    };
    
    var authorizeDevice = function(event) {
        var target = $(".authorize-device-link");
        var form = $('<form class="form-inline justify-content-center">');
        var deviceIdInput = $('<input type="text" placeholder="Name this device" class="form-control">');
        // var dismiss = '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>';
        // target.addClass("dismissable");
        var deviceIdOk = $('<input type="submit" value="ok" class="btn btn-secondary mx-1">');
        form.append(deviceIdInput);
        form.append(deviceIdOk);
        target.html(form);
        // target.append(dismiss);
        deviceIdInput.focus();
        target.off("click");
        
        deviceIdOk.click(submitAuthDevice);
    };
    
    var mount = function() {
        $('.stripe-connect').click(stripeConnect);
        $('.stripe-dashboard-link').click(stripeDashboard);
        $('.product-redeem-checkbox').click(enableProductSave);
        $('.authorize-device-link').click(authorizeDevice);        

    };
    
    return {mount: mount};
})();
