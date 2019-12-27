/* global $, m */
var MerchantProducts = (function() {
    
    var products = [];

    var oninit = function(vnode) {
        $.get("/api/products").then(function(data) {
            data.forEach(function(p) {products.push(p);}); 
        });
    };
    
    var toggleProduct = function(ev) {
        var checked = $(ev.target).prop("checked");
        var productId = $(ev.target).data("product-id");
        products.find(function(p) {return p.id === productId;}).redeem = checked;

    };
    
    var product_row = function(p) {
        return m("tr", [
                    m("td.text-center", m("input.form-check-input[type=checkbox]", {onclick: toggleProduct, "data-product-id": p.id, checked: p["can_redeem"]})),
                    m("td.text-left", p.name),
                    m("td", "$" + p.max_price_dollars.toFixed(2)),
                    ]);
    };
    
    var view = function(vnode) {
        
        var thead = m("thead", [
            m("th", {width: 10}, "Redeem?"),
            m("th.text-left", "Product"),
            m("th", "Price")]);
        
        var trows = products.map(function(p) {
            return product_row(p);
        });
        
        var tbody = m("tbody", trows);

        return [m(".h4.text-center", "Select Products"), m("table.table.overflow-auto", [thead, tbody])];
    };

    
    return {view: view, oninit: oninit, data: {products: products}};
})();
