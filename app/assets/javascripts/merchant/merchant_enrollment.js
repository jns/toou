/* global m */
var MerchantEnrollment = (function() {

    var nofeesstyle = ".nofees { font-weight: bold; text-decoration: blue wavy underline; }";

    
    var oninit = function(vnode) {
        var styleSheet = document.createElement("style");
        styleSheet.type = "text/css";
        styleSheet.innerText = nofeesstyle;
        document.head.appendChild(styleSheet);
    };
    
    var view = function(vnode) {
        return [m.trust("<div class=\"regular-16pt text-center\"><u>For Merchants</u></div>"),
                m.trust("<div class=\"m-4 text-center regular-14pt\">a <span class=\"toou\">tooU</span> is easy to redeem and costs you nothing.</div>" ),
                m.trust("<div class=\"m-4 text-center regular-14pt\">there are <span class=\"nofees\">NO FEES</span> for merchants.</div>"),
                m.trust("<div class=\"m-4 text-center regular-14pt\"><span class=\"toou\">tooU</span> will pay a premium for your products</div>"),
                m("table.mt-4.mx-auto", [
                    m("tr", [
                        m.trust("<td class=\"px-4\"><div class=\"d-inline-block product-icon beer\"></div><div class=\"d-inline-block\"><b>$10.00</b><br/> for a Beer</div></td>"),
                        m.trust("<td class=\"px-4\"><div class=\"d-inline-block product-icon coffee\"></div><div class=\"d-inline-block\"><b>$6.00</b><br/> for a Coffee</div></td>"),
                        ]),
                    m("tr.pt-5", [
                        m.trust("<td class=\"px-4\"><div class=\"d-inline-block product-icon treat\"></div><div class=\"d-inline-block\"><b>$6.00</b><br/> for a Dessert</div></td>"),
                        m.trust("<td class=\"px-4\"><div class=\"d-inline-block product-icon wine\"></div><div class=\"d-inline-block\"><b>$12.00</b><br/> for a Glass of Wine</div></td>"),
                        ])
                    ]),
                m(".m-4.text-center.regular-14pt", "All you need is a tablet or smart phone!"),
                m(".pb-5.text-center", m("a.btn.btn-primary", {href: "/merchants/onboard"}, "Get Started")),
                ];
    };
    
    return {oninit: oninit, view: view};
})();