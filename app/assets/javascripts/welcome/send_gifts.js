/* global $, m, Payment */

var ProductList = (function() {
    
    var products = [];
    
    var selectedProductId = null;
    
    var oninit = function() {
        fetchProducts();
        return null;
    };
    
    var fetchProducts = function() {
        m.request({
            method: "GET",
            url: "/api/products",
        }).then(function(data) {
            products = data;
        }).catch(function(e) {
        });
        return null;
    };
    
    var selectProduct = function(ev) {
        var target = $(ev.target).closest(".product"); 
        selectedProductId = target.data("product-id");
        
        var buyable = products.find(function(p) { return p.id === selectedProductId; });
        
        $('.recipient-form').show();
        $('.payment-form').show();
        Payment.setBuyable(buyable);
        
    };
    
    var view = function() {
        return products.map(function(p) { 
            var selected = (selectedProductId === p.id) ? ".selected" : "";
            return m(".product"+selected, {onclick: selectProduct, "data-product-id": p.id}, [
                m(".product-icon." + p.icon),
                m(".product-name", p.name),
                m(".product-price", "up to $" + p.max_price_dollars),
            ]);
        });
    };
    
    return {view: view, oninit: oninit};
})();

var RecipientForm = (function() {
    var view = function() {
        return m("form.mt-3", [
            m(".form-group.row", [
                m("label.col-sm-3.col-form-label.promo.p-0", "Send to:"),
                m("input.form-control.col-sm-9.text-center.p-0[id=recipient_phone][type=text][placeholder='10 digit phone']"),
                ])
            ]);
    };
    return {view: view};
})();


var SendGifts = (function() {
    
    
    var mount = function() {
        m.mount($('.product-list')[0], ProductList);
        m.mount($('.recipient-form')[0], RecipientForm);
        $('.recipient-form').hide();
        $('.payment-form').hide();
        return null;
    };
    
    return {mount: mount};
})();