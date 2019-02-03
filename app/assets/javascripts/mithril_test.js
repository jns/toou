//= require mithril_test/credentials
//= require mithril_test/hello
//= require mithril_test/goodbye
//= require mithril_test/login
//= require mithril_test/one_time_passcode
//= require mithril_test/passes
//= require mithril_test/splash
//= require mithril_test/promos

/* global m, $, Splash, Login, OneTimePasscode, Passes, Promos */

var Breadcrumb = (function() {
    
    // Shortcrumb to set the crumb to the default route and text
    var home = function() {
        show("Home", "/mithril")
    };
    
    var hide = function() {
        $('.nav-breadcrumb').hide();
    };
    
    var show = function() {
        if (arguments.length === 2) {
            setCrumb(arguments[0], arguments[1]);
        }
        $('.nav-breadcrumb').show();
    };
    
    var setCrumb = function(text, href) {
        $('#nav-breadcrumb-text').text(text);  
        $('a.nav-breadcrumb').attr("href", href);
    }; 
    
    return {hide: hide, show: show, setCrumb: setCrumb, home: home};
})();


$(document).on("turbolinks:load", function() {
    var root = document.getElementById('mithril_root');
    m.route(root, "/", {
        "/": Splash,
        "/login": Login,
        "/otp": OneTimePasscode,
        "/passes": Passes,
        "/promos": Promos,
        });
});