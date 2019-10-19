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


var SendGifts = (function() {
    
    
    var mount = function() {
        m.mount($('.product-list')[0], ProductList);
        m.mount($('.recipient-form')[0], RecipientForm);
        $(".message-form").hide();
        $('.recipient-form').hide();
        $('.payment-form').hide();
        return null;
    };
    
    return {mount: mount};
})();