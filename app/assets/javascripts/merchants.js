/* global $, Breadcrumb */

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
    }    
    
    var mount = function() {
        $('.stripe-connect').click(stripeConnect);
        $('.stripe-dashboard-link').click(stripeDashboard);
    };
    
    return {mount: mount};
})();
