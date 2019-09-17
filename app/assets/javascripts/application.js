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
//= require breadcrumb
//= require modal
//= require splash
//= require credentials

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

var addSignout = function() {
    if (Credentials.hasToken()) {
        Credentials.getUserData().then(function(data) {
            console.log(data);
            $(".sign-out").html("<div class=\"btn btn-link\">sign out</div>");
            $(".sign-out").click(function() {Credentials.setToken(); Routes.goHome();});
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
    
    
    if (path === "/send_gifts") {
        SendGifts.mount();
        Breadcrumb.home();
        addSignout();
    } else if (path === "/") {
        Splash.mount();
        Breadcrumb.hide();
        addSignout();
    } else if (path === "/passes") {
        Passes.mount();
        Breadcrumb.home();
        addSignout();
    } else if (path === "/merchants") {
        Breadcrumb.home();
    } else if (path.match(/\/merchants\/\d+/)) {
        Merchants.mount();
        Breadcrumb.show("Back", "/merchants");
    } else if (path.match(/\/pass\/.{30}/)) {
        Breadcrumb.show("Passes", "/passes");
        Pass.mount();
        addSignout();
    }else if (path === "/mredeem") {
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

