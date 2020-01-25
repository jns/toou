//= require ./credentials
//= require ./dispatcher

/* global Dispatcher, Credentials, m, $ */
var Navbar = (function() {
    
    
    var view = function() {
        var loggedIn = Credentials.isUserLoggedIn();

        return m("nav.navbar.navbar-expand-lg.bg-blue", 
            [m(m.route.Link, {href: "/", class: "navbar-brand"}, m("img", {width: 100, height: 50, src: window.toouAssets.toouLogoMini})),
             m("button.navbar-toggler", {type: "button", "data-toggle": "collapse", "data-target": "#navItems", "aria-controls": "navItems", "aria-expanded": false, "aria-label": "Toggle Navigation"},
                m("span.navbar-toggler-icon")),
             m(".collapse.navbar-collapse", {id: "navItems"}, 
                m("ul.navbar-nav", [
                    m("li.nav-item", m(m.route.Link, {href: "/merchants", class: "nav-link"}, (loggedIn ?  "Merchant Dashboard" : "For Merchants" ))),
                    m("li.nav-item", m(m.route.Link, {href: "/mredeem/toou", class: "nav-link"}, "Redeem a tooU")),
                    m("li.nav-item", m(m.route.Link, {href: "/about", class: "nav-link"}, "About")),
                    m("li.nav-item", m(m.route.Link, {href: "/support", class: "nav-link"}, "Support")),
                    (loggedIn ? m("li.nav-item", m(m.route.Link, {onclick: Credentials.logoutUser, href: "#"}, "Sign Out")) : null),
                    ])),
                ]);
    }
    
    return {view: view};
})();