var AuthorizeDevice = (function() {
    
    var task = Object.create(Task); 
    var dataStore = null;
    var showForm = false;
    var showDefer = false;
    var showAuthorized = false;
    
    var defer = function() {
        showDefer = true;
    };
    
    var displayForm = function() {
        showForm = true;
    };
    
    task.oninit = function(vnode) {
        dataStore = vnode.attrs;    
    };
    
    task.view = function(vnode) {
        
    
        var form = m("form.form.w-100.mt-5", {id: "authorize_device"}, [
            m("input.form-control", {type: "text", placeholder: "Name this device (ex. 'iPad #1')"}),
            m(".text-center.mt-3", m("input.btn.btn-primary", {type: "button", value: "Ok", onclick: authorizeNewDevice})),
            ])
        
        return m(".container",  [m(".row", m(".col", m(".h5.text-center", "Authorize this Device to Redeem TooU's?"))),
                                m(".row" + (showForm || showDefer ? ".d-none" : ""), [m(".col-sm-6.mt-5.text-center", m("input.btn.btn-outline.regular-20pt", {type: "button", onclick: defer, value: "No"})),
                                           m(".col-sm-6.mt-5.text-center", m("input.btn.btn-primary.regular-20pt", {type: "button", onclick: displayForm, value: "Yes"}))]),
                                m(".row" + (showForm ? "" : ".d-none"), form),
                                m(".row.col.text-center.mt-5.regular-12pt" + (showAuthorized ? ".d-inline-block" : ".d-none"), "This device is now authorized"),
                                m(".row.col.d-inline-block.text-center.mt-5.regular-12pt", ["You can authorize devices to redeem TooU's at any time by visiting ", m("a", {href: "https://www.toou.gifts/redeem"},"https://www.toou.gifts/redeem")]),
                                m(".row.justify-content-center.col.mt-5" + (showDefer || showAuthorized ? "" : ".d-none"), m("input.btn.btn-primary", {onclick: complete, value: "Ok"})),
                           ]);
    };
    
    var complete = function() {
        task.complete({}, null);
    }
    
    var authorizeNewDevice = function(ev) {
        if (dataStore.merchant) {
            var device_id = $('#authorize_device input[type="text"]').val();
            m.request({
                method: "POST",
                url: "/api/merchant/authorize_device",
                body: {authorization: Credentials.getUserToken(),
                    data: {merchant_id: dataStore.merchant.merchant_id, device_id: device_id}}
            }).then(function(data) {
                Credentials.setToken("REDEMPTION_TOKEN", data["auth_token"]);
                showAuthorized = true;
                showForm = false;
            }).catch(function(err) {
                alert(err); 
            });
        } else {
            alert("Cannot authorize device withour merchant id");
        }
    };

    
    return task;
})();
