/* global $, m, Breadcrumb */

var Home = (function() {
    
    var view = function() {
        return m(".container-fluid", [
            m(".row", [
                m(".col.text-center.mt-3", [
                    m("a[href='/send_gifts']", [
                        m(".buy-graphic"),
                        m("span.regular-20pt.darkgray", "Treat Someone")
                        ])
                    ])
                ]),
            m(".row", [
                m(".col.text-center.mt-3", [
                    m("a[href='/passes']", [
                        m(".drink-graphic"),
                        m("span.regular-20pt.darkgray", "My Drink Passes")
                        ])
                    ])
                ]),
            m(".row", [
                m(".col.text-center.mt-5", m("a[href='/merchants/new_user']", "Are you a merchant? Join the TooU Marketplace!")),
               ]),
            m(".row", [
                 m(".col.text-center.mt-5", m("a[href='/faq']", "Frequent Questions")),
                ]),
            m(".row", [
                 m(".col.text-center.mt-5", m("a[href='/about']", "About TooU")),
                ])
            ]);
    };
    
    return {view: view};
})();

var Splash = (function() {
    
    var mount = function() {
        Breadcrumb.hide();
       return m.mount($('#splash')[0], Home);
    }
    
    return {mount: mount};
})();