/* global m, Breadcrumb */

var Splash = (function() {
    
    var state_value = "";
    var redirect_uri = "https://" + window.location.hostname + "/#!/merchant";
    
    var client_id = "ca_EPUvudB7OLfL6IQbqmlFprVhyOu5xTIi";
    var stripe_oath_endpoint = "https://connect.stripe.com/express/oauth/authorize?client_id=" + client_id;
    
    var oninit = function() {
        Breadcrumb.hide();    
    };
    
    var onupdate = function() {
        Breadcrumb.hide();
    }
    
    var view = function() {
        return m(".container-fluid", [
            m(".row", [
                m(".col.text-center.mt-3", [
                    m("a[href='/promos']", {oncreate: m.route.link}, [
                        m(".buy-graphic"),
                        m("span.regular-20pt.darkgray", "Treat Someone")
                        ])
                    ])
                ]),
            // m(".row", [
            //     m(".col.text-center", [
            //         m("a[href='/promos']", {oncreate: m.route.link}, [
            //             m("div[id=HandGlass]")
            //             ])
            //         ])
            //     ]),
            m(".row", [
                m(".col.text-center.mt-3", [
                    m("a[href='/passes']", {oncreate: m.route.link}, [
                        m(".drink-graphic"),
                        m("span.regular-20pt.darkgray", "My Drink Passes")
                        ])
                    ])
                ]),
            m(".row", [
                m(".col.text-center.mt-5", m("a[href='/merchants']", "Are you a merchant? Join the TooU Marketplace!"))
                ])
            ]);
    };
    
    return {view: view, oninit: oninit, onupdate: onupdate};
})();