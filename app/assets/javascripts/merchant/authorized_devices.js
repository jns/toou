
var AuthorizedDevices = (function() {
    
    var merchant_id;
    var devices = [];
    var DEVICE_INFO = "";
    
    var oninit = function(vnode) {
        merchant_id = vnode.attrs.merchant.merchant_id;
        refresh();
    };
    
    var authorize = function() {
        if (DEVICE_INFO != "") {
            if (window.confirm("This device is already authorized, do you want to override?")) {
                Credentials.setToken("REDEMPTION_TOKEN", null);
            } else {
                return;
            }
        }
        m.route.set("/mredeem/toou");
    };
    
    var view = function(vnode) {
        
        if (vnode.attrs.merchant.merchant_id != merchant_id) {
            merchant_id = vnode.attrs.merchant.merchant_id;
            refresh();
            return m("Loading");
        } else {
            var contents ;
            if (devices.length > 0) {
                var items = devices.map(function(d){return addDeviceRow(d);});
                var contents = m("table.table", items);
            } else {
                contents = [m(".h3.p-3.text-center", "No Authorized Devices"), 
                            m(".h5.text-center", m("a.btn.btn-link", {onclick: authorize}, "Click Here to Authorize This Device"))];
            }
            
            return m("", contents);
        }
    };
    
    var addDeviceRow = function(dev) {
        var this_device = "";
        if (DEVICE_INFO === dev["device_id"]) {
            this_device = " (this device)";
        };
        return m("tr", [m("td", dev["device_id"] + this_device), 
                      m("td[data-device="+dev["id"]+"]", {onclick: deauthorizeDevice}, m(".btn-link", "deauthorize"))]);  
    };
    
    
    var deauthorizeDevice = function(ev) {
        var device_id = $(ev.target).closest("td").data("device");
        m.request({
            method: "POST",
            url: "/api/merchant/deauthorize",
            body: {authorization: Credentials.getUserToken(), 
                    data: {merchant_id: merchant_id, device_id: device_id}}
        }).then(function(data) {
            refresh();    
        });
    };
    
    var refresh = function() {
       m.request({
            url: "/api/merchant/authorized_devices",
            method: "post",
            body: {authorization: Credentials.getUserToken(),
                    data: {merchant_id: merchant_id}}
        }).then(function(data) {
            devices = data;
        });
        
        if (Credentials.hasToken("REDEMPTION_TOKEN")) {
            m.request({
                method: "POST", 
                url: "/api/redemption/device_info",
                body: {authorization: Credentials.getToken("REDEMPTION_TOKEN")}})
            .then(function(data) {
                DEVICE_INFO = data["device_id"];
            })
            .catch(function(error) {
                Credentials.setToken("REDEMPTION_TOKEN", null);
            });
        }
    };
    
    return {view: view, oninit: oninit, refresh: refresh};
})();