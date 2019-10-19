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
        $(".message-form").show();
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
