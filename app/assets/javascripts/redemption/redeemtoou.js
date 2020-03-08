/* global $, Credentials , m, Routes */
var MerchantInfo = (function() {
 
    var view = function(vnode) {

        if (vnode.attrs.name != undefined && vnode.attrs.address != undefined) {
            return m(".col-md.text-center", [m(".h5", vnode.attrs.name), m(".h6", vnode.attrs.address)]);
        } else if (vnode.attrs.error != undefined) {
            return m(".col-md.text-center.error", m(".h6", vnode.attrs.error));
        } else {
            return m(".text-center", m(".h3", "Merchant Not Found"));
        }
    };
    
    return {view: view};    
})();


var DeviceAuthorizationNameTask = (function() {
    
    var task = Object.create(Task);
    var errors = null;
    
    
    var authorize = function() {
        var merchant_id = $("[name*='merchant_id']").val();
        var device_id = $("[name*='device_id']").val();
        
        if (device_id.length === 0) {
            errors = "You must provide a device name";
            return;
        }
        
        var body = {authorization: Credentials.getUserToken(),
                    data: {merchant_id: merchant_id, device_id: device_id}};
                    
        m.request({method: "POST", 
            url: "/api/merchant/authorize_device",
            body: body}
        ).then(function(result) {
            console.log(result);
            Credentials.setToken("REDEMPTION_TOKEN", result["auth_token"]);
            task.complete(result);
        }).catch(function(err) {
            if (err.code == 401) {
                errors = "Timeout entering data. Please reload page.";
            } else if (err.code == 400) {
                errors = "You must name the device"; 
            }
        });
    };

    
    task.view = function(vnode) {
        
        var merchants = vnode.attrs.merchants;
        
        var merchant_input;
        if (typeof merchants == 'undefined' || merchants.length == 0) {
            return "";
        }
        
        if (merchants.length == 1) {
            merchant_input = m("input[type=hidden]", {name: "merchant_id", value: merchants[0].id});
        } else {
            var options = merchants.map(function(x) {return m("option", {value: x.id}, x.name) });
            merchant_input = m(".form-group.mt-3", [
                                m("label.label.text-left", "Merchant"),
                                m("select.form-control", {name: "merchant_id"}, options)
                                ]);
        }
        
        if (vnode.attrs.errors != undefined) {
            errors += vnode.attrs.errors;    
        }
        
        return m(".container-fluid.mx-auto.mt-3", [m(".h5.text-center", "Authorize This Device to Redeem TooUs"), 
                m(".error.text-center", errors),
                m(".form-group.text-center", [
                    m("label.label.text-left", "Name This Device"),
                    m("input.form-control[type='text'][name='device_id']", {placeholder: "e.g. Counter iPad 1"}),
                    merchant_input,
                    m("input.form-control.w-50.btn.btn-primary[type='button']", {onclick: authorize, value: "Authorize Device"})
                    ])]);
    };
    
    return task;
})();

var DeviceAuthorizationLoginTask = (function() {
    
    var email = null;
    var password = null;
    var error = null;

    var authenticate = function() {
        
        Credentials.authenticateUser(email, password).catch(function(err) {
            error = err;
        });
    };
    
    var view = function(vnode) {
        return m(".container-fluid.mt-3.mx-auto", 
                    [ m(".text-center.h3","Login to Authorize this Device"),
                      m(".text-center.error", error),
                      m(".form-group", [
                        m("label.label","Email"), 
                        m("input.form-control[type='text']", 
                            {value: email, 
                            onchange: function(e) { email = e.target.value }})
                        ]),
                      m(".form-group", [
                            m("label.label","Password"), 
                            m("input.form-control[type='password']",
                                {onchange: function(e) {password = e.target.value}, value: password})
                        ]),
                      m(".form-group.text-center", 
                            m("input.form-control.btn.btn-primary.w-50[type='button']",
                                {onclick: authenticate, value: "Submit"} )
                            ),
                      m(GoogleSignin, {destination: "/mredeem/toou"}),
                    ]);
    };
    
    return {view: view};
})();

var Overlay = (function() {
    
    var state = "hidden";
    
    var setState = function(value) {
        state = value;
    }
    
    var approved = function(amount, dom) {
        return [m("div", "Approved"), 
                m(".small", amount),
                m("input[value='Ok']", {class: "btn btn-outline-light", onclick: function(){setState("hidden")}})];
    };
    
    var denied = function(text, dom) {
        return [m("div", "Denied"), 
                m(".small", text),
                m("input[value='Ok']", {class: "btn btn-outline-light", onclick: function(){setState("hidden")}})];

    };
    
    var view = function(vnode) {
        if (state == "denied") {
            return m(".overlay", {class: "denied"}, denied(vnode.attrs.reason, vnode.attrs.element));
        } else if (state == "approved") {
            return m(".overlay", {class: "approved"}, approved(vnode.attrs.amount + " " + vnode.attrs.buyable_name, vnode.attrs.element));
        } else if (state == "pending") {
            return m(".overlay", {class: "pending"}, "Processing");
        } else {
            return null;
        }
        
    };
    
    return {view: view, setState: setState};
})();


var RedeemToou = (function() {
   
    var merchantList;
    var merchant;
    var recentTransactions = {transactions: []};
    var overlayAttrs = {};
    
    var loadTransactions = function() {
        var tok = Credentials.getToken("REDEMPTION_TOKEN");
        m.request({
            method: "POST",
            body: {authorization: tok},
            url: "/api/merchant/credits"
        }).then(function(credits) {
           if (credits.length > 0) {
                recentTransactions = {transactions: credits};
           }
        }).catch(function(error) {
            if (error.code == 401) {
                Credentials.setToken("REDEMPTION_TOKEN", null);   
            }
        });
    }
    
    var loadMerchantInfo = function() {
        var tok = Credentials.getToken("REDEMPTION_TOKEN");
        m.request({
            method: "POST",
            body: {authorization: tok},
            url: "/api/redemption/merchant_info"
        }).then(function(merchantData) {
            merchant = merchantData;
        }).catch(function(error) {
            if (error.code == 401) {
                Credentials.setToken("REDEMPTION_TOKEN", null);   
            }
        });
    }
   
    var initialize = function() {
        if (Credentials.hasToken("REDEMPTION_TOKEN")) {
            loadMerchantInfo();
            loadTransactions();
        } 
        
    };
    
    var shake = function(element) {
        element.animate({paddingLeft: "-=10px"}, 100)
            .animate({paddingLeft: "+=20px"}, 100)
            .animate({paddingLeft: "-=20px"}, 100)
            .animate({paddingLeft: "+=20px"}, 100)
            .animate({paddingLeft: "-=20px"}, 100)
            .animate({paddingLeft: "+=10px"}, 100);
    };
    
    
    var showPending = function() {
        Overlay.setState("pending");
    };
    
    var showOverlay = function(state, attrs) {
        Overlay.setState(state) 
        overlayAttrs = attrs;;
    };
    
    var hideOverlay = function() {
        Overlay.setState("hidden");
        overlayAttrs = {};
    };

    

    var codeInput = new CodeInput();
    var numberPad = new NumberPad(function(number) {
        if (number == "bs") {
            codeInput.decr();
        } else if ($.isNumeric(number)) {
            codeInput.incr(number);
            submitIfNeeded();
        }
    });
    
    var submit = function(code) {

        codeInput.clear();
        showPending();
        
        return m.request({
            method: "POST",
            url: "/api/redemption/redeem",
            body: {authorization: Credentials.getToken("REDEMPTION_TOKEN"), data: {code: code}}
        }).then(function(data) {
            showOverlay("approved", data);
            loadTransactions();
        }).catch(function(error) {
            if (error.code === 401) {
                hideOverlay();
            } else {
                var message = "";
                if (error.response.hasOwnProperty("unredeemable") ) {
                    if (typeof error.response.unredeemable == "array") {
                        error.response.unredeemable.forEach(function(e) {
                            message += e;
                        });
                    } else {
                        message = error.response.unredeemable;
                    }
                }
                showOverlay("denied", {reason: message});
                shake($(".overlay"));
            }
        });
    };
    
    var submitIfNeeded = function() {
        var code = codeInput.getCode();
        if (code.length == 4) {
            submit(code);
        }      
    };
    
    var loadUsersMerchants = function() {
        m.request({
            url: "/api/merchant/merchants",
            method: "POST", 
            body: {authorization: Credentials.getUserToken()}
        }).then(function(data) {
            merchantList = data;
        }).catch(function(err) {
            merchantList = [];
        });
    }
    
    var view = function() {
        if (Credentials.hasToken("REDEMPTION_TOKEN")) {    
            if (typeof merchant == 'undefined') {
                loadMerchantInfo();
            }
            return m(".container", [
                    m(Overlay, overlayAttrs), 
                    m(MerchantInfo, merchant), 
                    m(".row", [
                        m(".col-md", [m(codeInput), m(numberPad)]), 
                        m(".col-md", m(RecentCredits, recentTransactions))
                        ])
                    ]);
        } else if (Credentials.isUserLoggedIn()) {
            // Merchant is logged in, only device auth is needed
            if (merchantList) {            
                return m(DeviceAuthorizationNameTask, {merchants: merchantList});
            } else {
                loadUsersMerchants();
                return;
            }
        } else {
            // Merchant is not logged in.
           return m(DeviceAuthorizationLoginTask);
        }
        
    };
    
    
    return {oninit: initialize, view: view};
})();