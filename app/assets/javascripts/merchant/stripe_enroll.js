var StripeEnroll = (function() {
    
    var task = Object.create(Task);
    
    task.view = function(vnode) {
        console.log(vnode.attrs.merchant);
        return [m(".h5.text-center", "You're Almost Done!"),
                m(".h5.text-center", "Enrolling with Stripe is the final step to onboarding"), 
                m(".m-3.text-center", [m(StripeLink, {merchant: vnode.attrs.merchant}), 
                m(m.route.Link, {href: "/merchants/" + vnode.attrs.merchant.merchant_id, class: "btn btn-link"}, "I'll do it later")]),
                m("mt-5.text-center", m("a", {href: "https://stripe.com"}, "Stripe is used to process payments for millions of businesses around the world. Click to learn more about Stripe."))]
    };
    
    return task;
})();