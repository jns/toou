var MerchantFullInfo = (function() {
    
    
    var view = function(vnode) {
        var merchant = vnode.attrs.merchant;
        if (merchant) {
            return m("table.table.m-3", [
                m("tr", [m("td", "Name"), m("td", merchant.name)]),
                m("tr", [m("td", "Website"), m("td", merchant.website)]),
                m("tr", [m("td", "Phone Number"), m("td", merchant.phone_number)]),
                m("tr", [m("td", "Address"), m("td", merchant.formattedAddress())]),
                m("tr", [m("td.text-center", {colspan: 2}, m(StripeLink, {merchant: merchant}))]),
                ])
        } else {
            return "";
        }
    }
    
    return {view: view};
})();