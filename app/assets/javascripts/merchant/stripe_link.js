var StripeLink = (function() {
    
    var stripeLink = null;

    
    var onupdate = function(vnode) {
        if (! stripeLink && vnode.attrs.merchant) { 
            vnode.attrs.merchant.stripeLink().then(function(data) {
                stripeLink = data;
            }); 
        } 
    }
    
    var onremove = function() {
        stripeLink = null;
    }

    var view = function(vnode) {
        if (stripeLink) {
            var options = {href: stripeLink["url"], 
                          target: "_blank",
                          rel: "noreferrer noopener"};
            if (stripeLink["type"] == "connect") {
                return m("a.stripe-connect", options, m("span", "Connect With Stripe")); 
            } else {
                return m("a.btn-link", options, "Visit Stripe Dashboard");
            }
        } else {
            return "";
        }
    }
    
    return {view: view, onupdate: onupdate, onremove: onremove};
})();