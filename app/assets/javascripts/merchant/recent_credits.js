var RecentCredits = (function(){

    var currencyFormatter;
    
    if (typeof Intl == 'object') {
        currencyFormatter = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });
    } else {
        currencyFormatter = {format: function(value) {
            return "$" + value.toFixed(2);   
        }};
    }
    
    var tableRows = function(transactions) {
        return transactions.map(function(t) {
            var d = new Date(t.created_at);
            return m("tr", [
                m("td", d.toLocaleString()),
                m("td", currencyFormatter.format(t.amount_cents/100.0))
            ]);
        });
    };
    
    var view = function(vnode) {
        var content;
        var transactions = vnode.attrs.transactions;
        if (transactions.length > 0) {
            content = m("table.table.table-sm", m("tbody", tableRows(vnode.attrs.transactions)));
        } else {
            content = m(".h3.text-center", "No Transactions");
        }
        return m(".text-center",content);    
    };
    
    return {view: view};    
})();