//= require ./credentials
//= require ./dispatcher

/* global Dispatcher, Credentials, m, $ */
var Navbar = (function() {
    
    var logout = function() {
        collapse();
        Credentials.logoutUser();
    };
    
    var collapse = function() {
        $("#navItems").collapse("hide");  
    };
    
    var view = function() {
        var loggedIn = Credentials.isUserLoggedIn();

        return m("nav.navbar.navbar-expand-lg.bg-blue", 
            [m(m.route.Link, {href: "/", class: "navbar-brand", onclick: collapse}, m("img", {width: 100, height: 50, src: window.toouAssets.toouLogoMini})),
             m("button.navbar-toggler", {type: "button", "data-toggle": "collapse", "data-target": "#navItems", "aria-controls": "navItems", "aria-expanded": false, "aria-label": "Toggle Navigation"},
                m("span.navbar-toggler-icon")),
             m(".collapse.navbar-collapse", {id: "navItems"}, 
                m("ul.navbar-nav", [
                    m("li.nav-item", m(m.route.Link, {href: "/merchants", class: "nav-link", onclick: collapse}, (loggedIn ?  "Merchant Dashboard" : "For Merchants" ))),
                    m("li.nav-item", m(m.route.Link, {href: "/mredeem/toou", class: "nav-link", onclick: collapse}, "Redeem a tooU")),
                    m("li.nav-item", m(m.route.Link, {href: "/about", class: "nav-link", onclick: collapse}, "About")),
                    m("li.nav-item", m(m.route.Link, {href: "/support", class: "nav-link", onclick: collapse}, "Support")),
                    (loggedIn ? m("li.nav-item", m(m.route.Link, {onclick: logout, href: "/", class: "nav-link"}, "Sign Out")) : null),
                    ])),
                ]);
    }
    
    return {view: view};
})();