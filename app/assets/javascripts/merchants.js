/* global $, Breadcrumb */

var stripeConnect = function(event) {
    var stripe_connect_url;
    var merchant_id = $(event.currentTarget).data('merchant-id');
    if (typeof merchant_id != undefined && merchant_id !== null) {
        stripe_connect_url = "https://connect.stripe.com/express/oauth/authorize";
        stripe_connect_url += "?redirect_uri=https://toou-shapiroj.c9users.io/merchants/enroll";
        stripe_connect_url += "&client_id=ca_EPUvudB7OLfL6IQbqmlFprVhyOu5xTIi";
        stripe_connect_url += "&state="+merchant_id;
        window.location = stripe_connect_url;
    }

};

var setCrumb = function() {
    if (window.location.pathname === '/merchants') {
        Breadcrumb.home();   
    } else {
        Breadcrumb.show("Back", "/merchants");
    }
}

$(document).on("turbolinks:load", function() {
    $('.stripe-connect').click(stripeConnect);
    setCrumb();
});