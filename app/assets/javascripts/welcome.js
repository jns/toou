//= require_directory ./welcome
//= require_directory ./merchant

/* global m, $, Splash, Login, OneTimePasscode, Passes, Promos */


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