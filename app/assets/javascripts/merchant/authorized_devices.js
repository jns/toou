var AuthorizedDevices = (function() {
    
    var devices = [];
    var DEVICE_INFO = "";
    
    var oninit = function(vnode) {
        devices = vnode.attrs.devices;
        DEVICE_INFO = vnode.attrs.thisDevice;
    };
    
    var view = function(vnode) {
        
        var form = m("form.form-inline.justify-content-center.d-none", [
            m("input.form-control", {type: "text", placeholder: "Name this device"}),
            m("input.btn.btn-secondary.mx-1", {type: "submit", value: "Ok", onclick: authorizeNewDevice}),
            ])
            
        var add_device_alert = m(".alert.alert-warning.text-center", {onclick: displayAuthorizeDeviceForm}, [
                m("span.alert-link", "Click to Authorize This Device To Redeem TooUs"),
                form,
            ]);
        
        var contents = [];
        if (!Credentials.hasToken("REDEMPTION_TOKEN")) {
            contents.push(add_device_alert);
        } else {
 
        }
        
        var items =devices.map(function(d){return addDeviceRow(d);});
        var table = m("table.table", items);
        
        contents.push(table);
        
        return m("", contents);
    };
    
    var addDeviceRow = function(dev) {
        var this_device = "";
        if (DEVICE_INFO === dev["device_id"]) {
            this_device = " (this device)";
        };
        return m("tr", [m("td", dev["device_id"] + this_device), 
                      m("td[data-device="+dev["id"]+"]", {onclick: deauthorizeDevice}, m(".btn-link", "deauthorize"))]);  
    };
    
        
    var displayAuthorizeDeviceForm = function(event) {
        $("#authorized_devices .alert-link").hide();
        $("#authorized_devices form").removeClass("d-none");
    };
    
    var authorizeNewDevice = function(ev) {
        ev.preventDefault(); // suppress form submission
        var device_id = $('#authorized_devices input[type="text"]').val();
        m.request({
            method: "POST",
            url: "/api/merchant/authorize_device",
            body: {authorization: Credentials.getToken(),
                data: {merchant_id: MERCHANT_ID, device_id: device_id}}
        }).then(function(data) {
            Credentials.setToken("REDEMPTION_TOKEN", data["auth_token"]);
            refresh();
        });
    };
    
    var deauthorizeDevice = function(ev) {
        var device_id = $(ev.target).closest("td").data("device");
        m.request({
            method: "POST",
            url: "/api/merchant/deauthorize",
            body: {authorization: Credentials.getToken(), 
                    data: {merchant_id: MERCHANT_ID, device_id: device_id}}
        }).then(function() {
            refresh();
        });
    };
    
    var refresh = function() {
       m.request({
            url: "/api/merchant/authorized_devices",
            method: "post",
            body: {authorization: Credentials.getToken(),
                    data: {merchant_id: MERCHANT_ID}}
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
