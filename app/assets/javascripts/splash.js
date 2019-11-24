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
        if (merchants.length > 0) {
        return m(".row.mt-3", [
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
                        m("img.my-toous", {src: window.toouAssets.myToous}),
                        m("span.regular-14pt.poiret.shift-up-25px", "My tooU's")
                        ])
                    ]);
    };
    
    var sendTooU = function() {
        return  m(".col.text-center.mt-3", [
                    m("a[href='/send_gifts']", [
                        m("img.send-toou", {src: window.toouAssets.sendToou}),
                        m("span.regular-14pt.poiret.shift-up-25px", "Send tooU")
                        ])
                    ]);

    };
    
    var tagline = function() {
        return m(".regular-16pt.text-center", "Send treats to your friends.");
    };
    
    var merchantMap = function() {
        return m("a[href='merchant_map']", [m("img.map-graphic", {src: window.toouAssets.toouLogoMini}), m(".text-center.mt-0.poiret.regular-12pt", {style: "position: relative; top: -2.5em"}, "Click for participating merchants")]);
    };
    
    var navLinks = function() {
        return [m(".text-center.pt-1.mt-3.border-top", m("a[href='/mredeem/toou']", "Redeem a toou")),];
    };
    
    var view = function(vnode) {
        var leftTop = m(".left-top", tagline());
        var leftBottom = m(".left-bottom", [merchantMap(), m(MerchantLogos)]);
        var rightMiddle = m(".right-middle", [m(".row", sendTooU()),
                            m(".row", myTooUs()),
                            ]);
                                            
        return [ m(".splash-container", [leftTop, rightMiddle, leftBottom]) ];
    };
    
    return {view: view, oninit: oninit};
})();

var Splash = (function() {
    
    var mount = function() {
        Breadcrumb.hide();
       return m.mount($('#splash')[0], Home);
    };
    
    return {mount: mount};
})();