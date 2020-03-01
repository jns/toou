var StripeLink = (function() {
    
    var task = Object.create(Task);

    var addURL = function(url) {
        console.log(url);
    };

    task.view = function(vnode) {
        if (vnode.attrs.merchant) {
            vnode.attrs.merchant.stripeLink().then(function(url) { this.addUrl(url); });  
        }
        return m(".h3", "Stripe Link");
    }
    
    return task;
})();