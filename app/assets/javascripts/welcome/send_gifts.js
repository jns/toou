/* global $, m, Payment, ProductList */


var RecipientForm = (function() {
    
    var valueChanged = function(ev) {
        Payment.setRecipient(ev.target.value);
    };
    
    var view = function() {
        return m("form.mt-3", [
            m(".form-group.row", [
                m("label.col-sm-3.col-form-label.promo.p-0", "Send to:"),
                m("input.form-control.col-sm-9.text-center.p-0[id=recipient_phone][type=text][placeholder='10 digit phone']", {oninput: valueChanged}),
                ])
            ]);
    };
    return {view: view};
})();

var MessageForm = (function() {
    
    var view = function(vnode) {
        return m(".form-group.message-form", [
                m("label", {for: "message_input"}, "Custom Message"),
                m("input.form-control.text-center", {type: "text", id: "message_input", value: "Thanks!!"}),
            ]);
    };
    
    return {view: view};
})();

var PaymentOptions = (function() {
    
    var view = function() {
        return m(".payment-form.text-center", [
                m(".mt-3.mx-auto.w-50", {id: "payment-request-button"}),
                m(".mt-3.mx-auto", {id: "alternate-payment-button"}),
                m(".mx-auto.w-50", {id: "payment-errors"}),
            ]);    
    };
    
    return {view: view};

})();

var SendGifts = (function() {
    
    var view = function() {
        return m(".container", [
                m(".product-list-label", "What do you want to send?"),
                m(".text-center", m(ProductList)),
                m(".text-center", "Includes tax and tip"),
                m(MessageForm),
                m(RecipientForm),
                m(PaymentOptions)
            ]);
    };
    
    return {view: view};
})();