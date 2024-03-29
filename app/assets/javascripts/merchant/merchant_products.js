/* global $, m */
var MerchantProducts = (function() {
    
    var task = Object.create(Task);
    var dataStore = null;

    var submit = function() {
        task.complete({}, null);    
    };
    
    var toggleProduct = function(ev) {
        var checked = $(ev.target).prop("checked");
        var productId = $(ev.target).data("product-id");
        dataStore.merchant.products.find(function(p) {return p.id === productId;}).can_redeem = checked;
        dataStore.merchant.updateProducts();
    };
    
    var product_row = function(p) {
        return m("tr", [
                    m("td.text-center", m("input.form-check-input[type=checkbox]", {onclick: toggleProduct, "data-product-id": p.id, checked: p.can_redeem})),
                    m("td.text-left", p.name),
                    m("td", "$" + p.max_price_dollars.toFixed(2)),
                    ]);
    };
    
    task.oninit = function(vnode) {
        dataStore = vnode.attrs;
    };
    
    task.view = function(vnode) {
        var products = [];
        if (dataStore.merchant) {
            products = dataStore.merchant.products;
        }
        
        var thead = m("thead", [
            m("th", {width: 10}, "Redeem?"),
            m("th.text-left", "Product"),
            m("th", "Price")]);
        
        var trows = products.map(function(p) {
            return product_row(p);
        });
        
        var tbody = m("tbody", trows);

        return [m(".h4.text-center", "Select Products"), 
                m("table.table.overflow-auto", [thead, tbody]),
                m(".text-center.mt-5", m("input.btn.btn-primary", {onclick: submit, value: "Confirm"}))];
    };

    return task;
    
})();
