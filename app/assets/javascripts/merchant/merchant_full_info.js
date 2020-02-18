var MerchantFullInfo = (function() {
    
    var view = function(vnode) {
        var merchant = vnode.attrs.merchant;
        
        return m(".container.m-3", [
            m(".row", [m(".col", "Name"), m(".col", merchant.name)]),
            m(".row", [m(".col", "Website"), m(".col", merchant.website)]),
            m(".row", [m(".col", "Phone Number"), m(".col", merchant.phone_number)]),
            m(".row", [m(".col", "Address"), m(".col", merchant.formattedAddress())]),
            m(".row", [m(".col", "Stripe URL"), m(".col", m(StripeLink, {merchant: merchant}))]),
            ])
    }
    
    return {view: view};
})();