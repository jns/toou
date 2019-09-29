/** global m */
var MerchantProducts = (function() {
    
    var products = [];
    
    var oninit = function(vnode) {
        products = vnode.attrs.products;
    };
    
    var product_row = function(p) {
        return m("tr", [
                    m("td.text-center", m("input.form-check-input[type=checkbox]", {checked: p["can_redeem"]})),
                    m("td.text-left", p.name),
                    m("td", p.price_formatted),
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

        return m("table.table", [thead, tbody]);
    };

    
    return {view: view};
})();
