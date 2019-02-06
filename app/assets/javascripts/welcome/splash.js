/* global m */

var Splash = (function() {
    
    var oninit = function() {
        Breadcrumb.hide();    
    };
    
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
                m(".col.text-center.mt-5", "Are you a merchant? Join the TooU Marketplace! Start by checking in with Stripe below...")
                ]),
            m(".row", [
                m(".col.text-center.mt-2", [
                    m("a.stripe-connect", m("span", "Connect with Stripe"))
                    ])
                ]),
            ]);
    };
    
    return {view: view};
})();