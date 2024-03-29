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
//= require navbar
//= require modal
//= require modal2
//= require credentials
//= require splash
//= require redemption
//= require merchants
//= require user

/* global $, Breadcrumb, Credentials */

// Given User is not logged in:
//   if path == merchants
//      go to enrollment info
  
//   If path == dashboard
//      go to signin
//      go to dashboard
  
//   If path == onboard
//      login or create account
//      go to onboard workflow


// Given User is logged in:
var uuidv4 = function() {
  return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, function(c) {
    return (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16);
  });
}



$(function() {
    
    // Init the credentials
    Credentials.init();
    
    // Add navigation
    var nav = document.getElementById('navigation');
    var appContent = document.getElementById('app-content');
    var breadcrumbs = document.getElementById('breadcrumb');
    m.mount(nav, Navbar);
    m.route.prefix = '';
    m.route(appContent, "/", {
        "/": {onmatch: function(args, requestedPath, route) {
            document.title = "TooU";
            return Home;
        }},
        "/send_gifts": {onmatch: function(args, requestedPath, route) {
            document.title = "Send a TooU";
            return SendGifts;
        }},
        "/passes":{onmatch: function(args, requestedPath, route) {
            document.title = "My TooU's";
            return PassesComponent;
        }},
        "/pass/:sn": {onmatch: function(args, requestedPath, route) {
            document.title = "Redeem a TooU";
            return PassComponent;
        }},
        "/merchants": {onmatch: function(args, requestedPath, route) {
           if (Credentials.isUserLoggedIn()) {
               m.route.set("/merchants/dashboard");
           } else {
               document.title = "For Merchants";
               return MerchantEnrollment;
           }
        }},
        "/merchants/dashboard": {onmatch: function(args, requestedPath, route) {
            if (Credentials.isUserLoggedIn()) {
               document.title = "Merchant Dashboard";
               return MerchantDashboard;
           } else {
               return MerchantLogin;
           }
        }},
        "/merchants/onboard": {onmatch: function(args, requestedPath, route) {
            if (Credentials.isUserLoggedIn()) {
               document.title = "Merchants Onboard";
               return new MerchantOnboardWorkflow();
            } else {
                return MerchantLogin;
            }
        }},
        "/merchants/new": {onmatch: function(args, requestedPath, route) {
            if (Credentials.isUserLoggedIn()) {
                m.route.set("/merchants/dashboard");
            } else {
                document.title = "New Merchant Account";
                return MerchantNew;
            }
        }},
        "/merchants/:key": {onmatch: function(args, requestedPath, route) {
            document.title = "Merchant Home";
            return MerchantHome;
        }},
        "/mredeem": {onmatch: function(args, requestedPath, route) {
            document.title = "Redeem";
            return RedeemToou;
        }},
        "/redeem": {onmatch: function(args, requestedPath, route) {
            document.title = "Redeem";
            return RedeemToou;
        }},
        "/mredeem/toou": {onmatch: function(args, requestedPath, route) {
            document.title = "Redeem";
            return RedeemToou;
        }},
        "/password_reset": {onmatch: function(args, requestedPath, route) {
            document.title = "Password Reset";
            return PasswordResetRequest;
        }},
        "/password_reset/:token": {onmatch: function(args, requestedPath, route) {
            document.title = "Password Reset";
            return PasswordReset;
        }},
    });
    
    var crumbs = new Breadcrumb([
       {regex: new RegExp("/send_gifts"), href: "/", text: "Home"},
       {regex: new RegExp("/passes"), href: "/", text: "Home"},
       {regex: new RegExp("/pass/.*"), href: "/passes", text: "Passes"},
       {regex: new RegExp("/merchants/\\d+"), href: "/merchants/dashboard", text: "Dashboard"},
    ]);
    m.mount(breadcrumbs, crumbs);

//    var path = window.location.pathname;

    // if (path === "/send_gifts") {
    //     SendGifts.mount();
    //     Breadcrumb.home();
    // } else if (path === "/") {
    //     Splash.mount();
    //     Breadcrumb.hide();
    // } else if (path === "/passes") {
    //     Passes.mount();
    //     Breadcrumb.home();
    // } else if (path.match(/\/merchants/)) {
    //     Breadcrumb.home();
    //     Merchants.mount(path); 
    // } else if (path.match(/\/merchants\/\d+/)) {
    //     // Merchants.mount();
    //     Breadcrumb.show("Back", "/merchants");
    // } else if (path.match(/\/pass\/.{30}/)) {
    //     Breadcrumb.show("Passes", "/passes");
    //     Pass.mount();
    // } else if (path === "/goArmy" || path === "/goarmy" || path === "/oorah" || path === "/flyfightwin" || path === "/bornready" || path === "/gonavy") { 
    //     Breadcrumb.home();
    //     GroupBeerPayment.mount();
    // } else if (path === "/mredeem") {
    //     RedeemLogin.mount();
    //     Breadcrumb.hide();
    // } else if (path === "/mredeem/toou") {
    //     RedeemToou.mount();
    //     Breadcrumb.hide();
    // } else if (path == "/admin") {
    //     Breadcrumb.hide();
    // } else if (path.match(/admin\/.*/)) {
    //     Breadcrumb.show("Dashboard", "/admin");
    // } else {
    //     Breadcrumb.home();
    // }
    
});

