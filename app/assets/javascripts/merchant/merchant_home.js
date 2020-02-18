
/* global m */
var MerchantHome = (function () {
    
    var error = "";
    var merchant = new Merchant();
    var transactions = [];

    var tabs = function(components) {
        var tabLinks = components.map(function(c) {
            return m("li.nav-item", m("a.nav-link", {id: c.id+"-tab", href: "#" + c.id, "data-toggle": "tab", role: "tab", "aria-controls": c.id, "aria-selected": "false"}, c.name)); 
        });
        var tabPanels = components.map(function(c) {
            return m(".tab-pane.fade.p-3", {id: c.id, role: "tabpanel", "aria-labelledby": c.id + "-tab"}, m(c.component, c.attrs));
        });
        var tabContent = m(".tab-content", {id: "TabContent"}, tabPanels )
        
        if (components.length > 0) {
            tabLinks[0].children[0].attrs["aria-selected"] = "true";
            tabLinks[0].children[0].attrs.className += " active show";
            tabPanels[0].attrs.className += " active show";
        }
        return [m("ul.nav.nav-tabs", {id: "Tabs", role: "tablist"}, tabLinks), tabContent];
    };
    
    var oninit = function(vnode) {
        m.request({url: "/api/merchant", 
            method: "POST",
            body: {authorization: Credentials.getUserToken(), data: {merchant_id: vnode.attrs.key}}
        }).then(function(data){
            merchant.initialize(data);
        }).catch(function(err) {
            error = "Merchant not found";
        })
        m.request({url: "/api/merchant/credits", 
                   method: "POST",
                   body: {authorization: Credentials.getUserToken(), data: {merchant_id: vnode.attrs.key}}
        }).then(function(data) {
            transactions = data;    
        })
        
    };
    
    var view = function(vnode) {

        if (error) {
            return m(".content-width.text-center", error);
        } else if (merchant.merchant_id) {
            return m(".content-width", [
                        m(MerchantFullInfo, {merchant: merchant}), 
                        tabs([{name: "Products", id: "Products", component: MerchantProducts, attrs: {merchant: merchant}},
                              {name: "Authorized Devices", id: "AuthorizedDevices", component: AuthorizedDevices, attrs: {merchant: merchant}},
                              {name: "Credits", id: "Credits", component: RecentCredits, attrs: {transactions: transactions}}])
                        ]);
        } else {
            return m(".content-width.text-center", "Loading ...");
        }
    };
    
    return {view: view, oninit: oninit};
})();