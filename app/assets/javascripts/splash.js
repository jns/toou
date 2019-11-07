/* global $, m, Breadcrumb */

var MerchantLogos = (function() {
    
    var merchants = [];
    var idx = 0;
    
    var shuffle = function(a) {
        for (var i = a.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [a[i], a[j]] = [a[j], a[i]];
        }
        return a;
    };
    
    var nextIndex = function() {
        if (++idx >= merchants.length) {
            idx = 0;
        }
        return idx;
    }
    
    var replace = function(logo_num) {
        setTimeout(function() {
            var im = $("img.logo-"+logo_num);
            im.fadeOut(500, function() {
                im.attr("src", merchants[nextIndex()]["logo"]);
                im.on("load", function(ev) {$(this).fadeIn(500);})
            });
            replace((logo_num + 1) % 3);
        }, 3000);
    };
    
    var oninit = function(vnode) {
        m.request({url: "/api/merchants",
                    method: "POST", 
                    body: {}})
        .then(function(data) {
                        merchants = shuffle(data);
                        replace(0);
                    });
    };
    
    var view = function(vnode) {
        if (merchants.length > 1) {
        return m(".row", [
                m("div", {style: "height: 75px"}),
                m(".col-4.text-right", m("img.logo.logo-0", {src: merchants[nextIndex()]["logo"], height: 75})),
                m(".col-4.text-center", m("img.logo.logo-1", {src: merchants[nextIndex()]["logo"], height: 75})),
                m(".col-4.text-left", m("img.logo.logo-2", {src: merchants[nextIndex()]["logo"], height: 75})),
                ]);
        }
    };
    
    return {view: view, oninit: oninit};
})();

var Home = (function() {
    

    var oninit = function() {
    };
    
    var myTooUs = function() {
        return  m(".col.text-center.mt-3", [
                    m("a[href='/passes']", [
                        m(".my-toous"),
                        m("span.regular-14pt.poiret.shift-up-35px", "My tooU's")
                        ])
                    ]);
    };
    
    var sendTooU = function() {
        return  m(".col.text-center.mt-3", [
                    m("a[href='/send_gifts']", [
                        m(".send-toou"),
                        m("span.regular-14pt.poiret.shift-up-35px", "Send tooU")
                        ])
                    ]);

    };
    
    var merchantMap = function() {
        return m(".col.text-center.mt-5.h5", m("a[href='merchant_map']", "Map of Participating Merchants"));
    };
    
    var navLinks = function() {
        return [ m(".col-sm-3.text-center.pt-3", m("a[href='/merchants/new_user']", "For Merchants")),
                m(".col-sm-3.text-center.pt-3", m("a[href='/mredeem/toou']", "Redeem a toou")),
                 m(".col-sm-3.text-center.pt-3", m("a[href='/about']", "About tooU")),
                 m(".col-sm-3.text-center.pt-3", m("a[href='/support']", "Contact Us")),
                ];
    };
    
    var view = function(vnode) {
        var leftCol = m(".col.order-last", m(".map-graphic"));
        var rightCol = m(".col.p-0.mx-auto", [m(".row", sendTooU()),
                            m(".row", myTooUs()),
                            m(".row", merchantMap()),
                            m(MerchantLogos),
                            m(".row.mt-5.border-top", navLinks()),
                            ]);
                                            
        return [m(".container",  m(".row", [leftCol, rightCol]))];
    };
    
    return {view: view, oninit: oninit};
})();

var Splash = (function() {
    
    var mount = function() {
        Breadcrumb.hide();
       return m.mount($('#splash')[0], {view: function() {return m(Home, {merchant_logos: []});}});
    };
    
    return {mount: mount};
})();