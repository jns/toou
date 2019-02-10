//= require_directory ./welcome

/* global m, $, Splash, Login, OneTimePasscode, Passes, Promos */


$(document).on("turbolinks:load", function() {
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
    }
    
    if (path === "/") {
        Splash.mount();
        Breadcrumb.hide();
    }
    
    if (path === "/passes") {
        Passes.mount();
        Breadcrumb.home();
    }
    
});