//= require ./merchant/merchant_autocomplete
//= require ./merchant/merchant_onboard
//= require ./merchant/merchant_products
//= require ./merchant/merchant_address_form

/* global m, $, Breadcrumb, Credentials */

var MERCHANT_ID = 0;


var AuthorizedDevices = (function() {
    
    var devices = [];
    var DEVICE_INFO = "";
    
    var oninit = function() {
        refresh();
        $('.authorize-device-link').click(displayAuthorizeDeviceForm);
    };
    
    var view = function() {
        
        var form = m("form.form-inline.justify-content-center.d-none", [
            m("input.form-control", {type: "text", placeholder: "Name this device"}),
            m("input.btn.btn-secondary.mx-1", {type: "submit", value: "Ok", onclick: authorizeNewDevice}),
            ])
            
        var add_device_alert = m(".alert.alert-warning.text-center", {onclick: displayAuthorizeDeviceForm}, [
                m("span.alert-link", "Click to Authorize This Device To Redeem TooUs"),
                form,
            ]);
        
        var contents = [];
        if (!Credentials.hasToken("REDEMPTION_TOKEN")) {
            contents.push(add_device_alert);
        } else {
 
        }
        
        var items =devices.map(function(d){return addDeviceRow(d);});
        var table = m("table.table", items);
        
        contents.push(table);
        
        return m("", contents);
    };
    
    var addDeviceRow = function(dev) {
        var this_device = "";
        if (DEVICE_INFO === dev["device_id"]) {
            this_device = " (this device)";
        };
        return m("tr", [m("td", dev["device_id"] + this_device), 
                      m("td[data-device="+dev["id"]+"]", {onclick: deauthorizeDevice}, m(".btn-link", "deauthorize"))]);  
    };
    
        
    var displayAuthorizeDeviceForm = function(event) {
        $("#authorized_devices .alert-link").hide();
        $("#authorized_devices form").removeClass("d-none");
    };
    
    var authorizeNewDevice = function(ev) {
        ev.preventDefault(); // suppress form submission
        var device_id = $('#authorized_devices input[type="text"]').val();
        m.request({
            method: "POST",
            url: "/api/merchant/authorize_device",
            body: {authorization: Credentials.getToken("MERCHANT_TOKEN"),
                data: {merchant_id: MERCHANT_ID, device_id: device_id}}
        }).then(function(data) {
            Credentials.setToken("REDEMPTION_TOKEN", data["auth_token"]);
            refresh();
        });
    };
    
    var deauthorizeDevice = function(ev) {
        var device_id = $(ev.target).closest("td").data("device");
        m.request({
            method: "POST",
            url: "/api/merchant/deauthorize",
            body: {authorization: Credentials.getToken("MERCHANT_TOKEN"), 
                    data: {merchant_id: MERCHANT_ID, device_id: device_id}}
        }).then(function() {
            refresh();
        });
    };
    
    var refresh = function() {
       m.request({
            url: "/api/merchant/authorized_devices",
            method: "post",
            body: {authorization: Credentials.getToken("MERCHANT_TOKEN"),
                    data: {merchant_id: MERCHANT_ID}}
        }).then(function(data) {
            devices = data;
        });
        
        if (Credentials.hasToken("REDEMPTION_TOKEN")) {
            m.request({
                method: "POST", 
                url: "/api/redemption/device_info",
                body: {authorization: Credentials.getToken("REDEMPTION_TOKEN")}})
            .then(function(data) {
                DEVICE_INFO = data["device_id"];
            })
            .catch(function(error) {
                Credentials.setToken("REDEMPTION_TOKEN", null);
            });
        }
    };
    
    return {view: view, oninit: oninit, refresh: refresh};
})();

var Merchants = (function() {

    var client_id;
    
    var get_stripe_id = function() {
        return new Promise(function (resolve, reject) {
            $.get("/keys/stripe_client_id", function(data) {
                resolve(data["stripe_client_id"]);
            });
        });
    };
        
    var get_merchant_token = function() {
        return new Promise(function(resolve, reject) {
            $.get("/merchants/token")
                .done(function(data) {
                   var token = data["auth_token"];
                    Credentials.setToken("MERCHANT_TOKEN", token);
                    resolve();
                })
                .fail(function() {
                   Credentials.setToken("MERCHANT_TOKEN", null); 
                   reject();
                });
        });
    };

    var stripeConnect = function(event) {
        var stripe_connect_url;
        var merchant_id = $(event.currentTarget).data('merchant-id');
        
        if (typeof merchant_id != undefined && merchant_id !== null) {
            m.request({
                method: "POST",
                url: "/api/merchant/stripe_link",
                body: {authorization: Credentials.getToken("MERCHANT_TOKEN"),
                        data: {merchant_id: merchant_id}}
            }).then(function(data){
                console.log(data.url);
                window.location = data.url;
            }).catch(function(error){
                console.log(error);
            });
            //     stripe_connect_url = "https://connect.stripe.com/express/oauth/authorize";
        //     stripe_connect_url += "?redirect_uri=https://" + window.location.host + "/merchants/enroll";
        //     stripe_connect_url += "&client_id=" + client_id;
        //     stripe_connect_url += "&state="+merchant_id;
        //     stripe_connect_url += "&stripe_user[business_type]=company";
        //     stripe_connect_url += "&stripe_user[email]=";
        //     stripe_connect_url += "&stripe_user[business_name]=";
        //     stripe_connect_url += "&stripe_user[phone_number]=";
        //     window.location = stripe_connect_url;
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


    
    var mount = function() {
        MERCHANT_ID = $('.merchant-data').data('merchant-id');
        $('.stripe-connect').click(stripeConnect);
        $('.stripe-dashboard-link').click(stripeDashboard);
        $('.product-redeem-checkbox').click(enableProductSave);

        get_stripe_id().then(function(data) {
            stripe_id = data;
        });
        get_merchant_token().then(function() {
            m.mount($('#authorized_devices')[0], AuthorizedDevices);
        });
    };
    
    return {mount: mount};
})();
