//= require ./credentials
//= require ./dispatcher

/* global Dispatcher, Credentials, m, $ */
var Navbar = (function() {
    
    
    var view = function() {
        var loggedIn = Credentials.isUserLoggedIn();

        return m("nav.navbar.navbar-expand-lg.bg-blue", 
            [m("a.navbar-brand", {href: "/"}, m("img", {width: 100, height: 50, src: window.toouAssets.toouLogoMini})),
             m("button.navbar-toggler", {type: "button", "data-toggle": "collapse", "data-target": "#navItems", "aria-controls": "navItems", "aria-expanded": false, "aria-label": "Toggle Navigation"},
                m("span.navbar-toggler-icon")),
             m(".collapse.navbar-collapse", {id: "navItems"}, 
                m("ul.navbar-nav", [
                    m("li.nav-item", m("a.nav-link", {href: "/merchants"}, "Merchant Dashboard")),
                    m("li.nav-item", m("a.nav-link", {href: "/mredeem/toou"}, "Redeem a tooU")),
                    m("li.nav-item", m("a.nav-link", {href: "/about"}, "About")),
                    m("li.nav-item", m("a.nav-link", {href: "/support"}, "Support")),
                    (loggedIn ? m("li.nav-item", m("a.nav-link", {onclick: Credentials.logoutUser, href: "#"}, "Sign Out")) : null),
                    ])),
                ]);
    }
    
    return {view: view};
})();