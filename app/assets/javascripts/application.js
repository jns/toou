// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require popper
//= require bootstrap
//= require jquery_ujs
//= require dispatcher
//= require mutex
//= require assets
//= require google_signin
//= require breadcrumb
//= require modal
//= require modal2
//= require credentials
//= require splash

/* global $, Breadcrumb, Credentials */

var Routes = {
    goHome: function() { 
        window.location.pathname = "/";
    },
    
    deviceNotAuthorized: function() {
        window.location.pathname = "/mredeem/not_authorized";
    },
    
    goRedeem: function() {
        window.location.pathname = "/mredeem/toou";
        // Turbolinks.visit("/mredeem/toou", {action: "replace"});
    }
};

var uuidv4 = function() {
  return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, function(c) {
    return (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16);
  });
}


var addSignout = function() {
    if (Credentials.hasToken()) {
        Credentials.getUserData().then(function(data) {
            $(".navbar-nav").append("<li class=\"nav-item\"><a href=\"/logout\" class=\"nav-link signout\">logout " + data.name + "</a></li>");
            $(".signout").click(function() {Credentials.setToken(); Routes.goHome();});
        });
    }
};

$(function() {
    // var root = document.getElementById('mithril_root');
    // m.route(root, "/", {
    //     "/": Splash,
    //     "/login": Login,
    //     "/otp": OneTimePasscode,
    //     "/passes": Passes,
    //     "/promos": Promos,
    //     });
    

    var path = window.location.pathname;
    
    addSignout();
    
    if (path === "/send_gifts") {
        SendGifts.mount();
        Breadcrumb.home();
    } else if (path === "/") {
        Splash.mount();
        Breadcrumb.hide();
    } else if (path === "/passes") {
        Passes.mount();
        Breadcrumb.home();
    } else if (path == "/merchants/onboard1") {
        MerchantOnboard.mount();
        Breadcrumb.home();
    } else if (path === "/merchants") {
        Breadcrumb.home();
    } else if (path.match(/\/merchants\/\d+/)) {
        Merchants.mount();
        Breadcrumb.show("Back", "/merchants");
    } else if (path.match(/\/pass\/.{30}/)) {
        Breadcrumb.show("Passes", "/passes");
        Pass.mount();
    } else if (path === "/goArmy" || path === "/goarmy" || path === "/oorah" || path === "/flyfightwin" || path === "/bornready" || path === "/gonavy") { 
        Breadcrumb.home();
        GroupBeerPayment.mount();
    } else if (path === "/mredeem") {
        RedeemLogin.mount();
        Breadcrumb.hide();
    } else if (path === "/mredeem/toou") {
        RedeemToou.mount();
        Breadcrumb.hide();
    } else if (path == "/admin") {
        Breadcrumb.hide();
    } else if (path.match(/admin\/.*/)) {
        Breadcrumb.show("Dashboard", "/admin");
    } else {
        Breadcrumb.home();
    }
    
});

