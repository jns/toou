//= require mithril_test/credentials
//= require mithril_test/hello
//= require mithril_test/goodbye
//= require mithril_test/login
//= require mithril_test/one_time_passcode
//= require mithril_test/passes
//= require mithril_test/splash
//= require mithril_test/promos

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