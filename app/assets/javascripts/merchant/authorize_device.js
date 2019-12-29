var AuthorizeDevice = (function() {
    
    var task = Object.create(Task); 
    var showForm = false;
    var showDefer = false;
    
    var defer = function() {
        showDefer = true;
    };
    
    var displayForm = function() {
        showForm = true;
    };
    
    task.view = function(vnode) {
        
    
        var form = m("form.form.w-100.mt-5", {id: "authorize_device"}, [
            m("input.form-control", {type: "text", placeholder: "Name this device (ex. 'iPad #1')"}),
            m(".text-center.mt-3", m("input.btn.btn-primary", {type: "button", value: "Ok", onclick: authorizeNewDevice})),
            ])
        
        return m(".container",  [m(".row", m(".col", m(".h5.text-center", "Authorize this Device to Redeem TooU's"))),
                                m(".row" + (showForm || showDefer ? ".d-none" : ""), [m(".col-sm-6.mt-5.text-center", m("input.btn.btn-outline.regular-20pt", {type: "button", onclick: defer, value: "No"})),
                                           m(".col-sm-6.mt-5.text-center", m("input.btn.btn-primary.regular-20pt", {type: "button", onclick: displayForm, value: "Yes"}))]),
                                m(".row" + (showForm ? "" : ".d-none"), form),
                           ]);
    };
    
    
    var authorizeNewDevice = function(ev) {
        var device_id = $('#authorize_device input[type="text"]').val();
        m.request({
            method: "POST",
            url: "/api/merchant/authorize_device",
            body: {authorization: Credentials.getUserToken(),
                data: {merchant_id: MERCHANT_ID, device_id: device_id}}
        }).then(function(data) {
            Credentials.setToken("REDEMPTION_TOKEN", data["auth_token"]);
            refresh();
        });
    };

    
    return task;
})();
