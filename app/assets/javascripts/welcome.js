//= require_directory ./welcome

/* global m, $, Splash, Login, OneTimePasscode, Passes, Promos */

var Breadcrumb = (function() {
    
    // Shortcrumb to set the crumb to the default route and text
    var home = function() {
        show("Home", "/")
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