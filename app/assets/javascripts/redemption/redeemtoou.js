/* global $, Credentials , m, Routes */
var MerchantInfo = (function() {

    var view = function(vnode) {
        if (vnode.attrs.name != undefined && vnode.attrs.address != undefined) {
            return m(".text-center", [m(".h3", vnode.attrs.name), m(".h6", vnode.attrs.address)]);
        } else {
            return m(".text-center", m(".h3", "Merchant Not Found"));
        }
    };
    
    return {view: view};    
})();

var DeviceAuthorizationName = (function() {
    var secret = null;
    var errors = null;
    
    var oninit = function(vnode) {
        secret = vnode.attrs.secret;  
    };
    
    var authorize = function() {
        var merchant_id = $("[name*='merchant_id']").val();
        var device_id = $("[name*='device_id']").val();
        
        if (device_id.length === 0) {
            errors = "You must provide a device name";
            m.redraw();
            Modal.enableOkButton();
            return;
        }
        
        var body = {authorization: {secret: secret},
                    data: {merchant_id: merchant_id, device_id: device_id}};
                    
        return new Promise(function(resolve, reject) {
            m.request({method: "POST", 
                url: "/api/merchant/authorize_device",
                body: body}
            ).then(function(result) {
                resolve(result);
            }).catch(function(err) {
                if (err.code == 401) {
                    reject({error: "Timeout entering data. Please reload page."});
                } else if (err.code == 400) {
                    reject({error: "You must name the device"}); 
                }
            });
        });  
    };
    
    var view = function(vnode) {
        var merchants = vnode.attrs.merchants;
        var merchant_input;
        if (merchants.length == 1) {
            merchant_input = m("input[type=hidden]", {name: "merchant_id", value: merchants[0].id});
        } else {
            var options = merchants.map(function(x) {return m("option", {value: x.id}, x.name) });
            merchant_input = m(".form-group", [
                                m("label.label", "Merchant"),
                                m("select.form-control", {name: "merchant_id"}, options)
                                ]);
        }
        
        if (vnode.attrs.errors != undefined) {
            errors += vnode.attrs.errors;    
        }
        
        return [m(".error.text-center", errors),
                m(".form-group", [
                    m("label.label", "Name This Device"),
                    m("input.form-control[type='text'][name='device_id']", {placeholder: "e.g. Counter iPad 1"})
                    ]),
                merchant_input];
    };
    
    return {view: view, oninit: oninit, okClicked: authorize};
})();

var DeviceAuthorizationLogin = (function() {
    
    var email = null;
    var password = null;

    var authenticate = function() {
        
        body = {authorization: {email: email, password: password}};
        return new Promise(function(resolve, reject) {
            m.request({method: "POST", 
                url: "/api/merchant/authorize_device",
                body: body}
            ).then(function(data) {
                resolve(data);      
            }).catch(function(err) {
                if (err.code == 401) {
                    reject({error: "Invalid email or password", email: email});
                } else {
                    reject(err);
                }
            })
        })
    };
    
    var view = function(vnode) {
        return m(".container-fluid.mt-3.mx-auto", 
                    [
                    m(".row",
                        m(".col.text-center",
                            m("span.error", vnode.attrs.error))),
                    m(".row", 
                        m(".col", 
                            m(".form-group", [
                                m("label.label","Email"), 
                                m("input.form-control[type='text']", 
                                    {value: email, 
                                    oninput: function(e) { email = e.target.value }})
                        ]))),
                    m(".row", 
                        m(".col",
                            m(".form-group", [
                                m("label.label","Password"), 
                                m("input.form-control[type='password']",
                                    {oninput: function(e) {password = e.target.value}}
                                    )
                        ])))
                    ]);
    };
    
    return {view: view, okClicked: authenticate};
})();

var Overlay = (function() {
    
    var detach = function(domElement) {
        m.mount($(domElement)[0], null);
    };
    
    var approved = function(amount, dom) {
        return [m("div", "Approved"), 
                m(".small", amount),
                m("input[value='Ok']", {class: "btn btn-outline-light", onclick: function(){detach(dom);}})];
    };
    
    var denied = function(text, dom) {
        return [m("div", "Denied"), 
                m(".small", text),
                m("input[value='Ok']", {class: "btn btn-outline-light", onclick: function(){detach(dom);}})];

    };
    
    var view = function(vnode) {
        if (vnode.attrs.state == "denied") {
            return m(".overlay", {class: "denied"}, denied(vnode.attrs.reason, vnode.attrs.element));
        } else if (vnode.attrs.state == "approved") {
            return m(".overlay", {class: "approved"}, approved(vnode.attrs.amount, vnode.attrs.element));
        } else {
            return m(".overlay", {class: "pending"}, "Processing");
        }
        
    };
    
    return {view: view, detach: detach};
})();

var RedeemToou = (function() {
    
    // Which code input to highlight first
    var inputIndex = 1;
    
    var loadMerchantData = function() {
        if (Credentials.hasToken("REDEMPTION_TOKEN")) {
            m.request({
                method: "POST",
                body: {authorization: Credentials.getToken("REDEMPTION_TOKEN")},
                url: "/api/redemption/merchant_info"
            }).then(function(merchantData) {
                m.mount($(".merchant-info")[0],{view: function() { return m(MerchantInfo, merchantData)}});
            }).catch(function(error) {
                if (error.code === 401) {
                    Credentials.setToken();
                    authenticate();
                }
            });
        }
    };
    
    var authzSuccess = function(result) {
        Credentials.setToken("REDEMPTION_TOKEN", result.auth_token);
        Modal.setBody("Device Authorization Successful");
        Modal.setOkButton("Ok", Modal.dismiss);
    } ;
    
    var authxSuccess = function(result) {
        Modal.setBody(DeviceAuthorizationName, result);
        Modal.setOkButton("Authorize", authzSuccess);
    };
    
    var authenticate = function() {
        Modal.setTitle("Authorize This Device");
        Modal.setBody(DeviceAuthorizationLogin);
        Modal.setOkButton("Submit", authxSuccess);
        Modal.show(loadMerchantData);
    }
    
    var shake = function(element) {
        element.animate({paddingLeft: "-=10px"}, 100)
            .animate({paddingLeft: "+=20px"}, 100)
            .animate({paddingLeft: "-=20px"}, 100)
            .animate({paddingLeft: "+=20px"}, 100)
            .animate({paddingLeft: "-=20px"}, 100)
            .animate({paddingLeft: "+=10px"}, 100);
    };
    
    var clear = function() {
        $("#code-1").val("").removeClass("focus");
        $("#code-2").val("").removeClass("focus");
        $("#code-3").val("").removeClass("focus");
        $("#code-4").val("").removeClass("focus");
        
        inputIndex = 1;
        $("#code-1").addClass("focus");
    };
    
    var showPending = function() {
        m.mount($("#overlay")[0], {view: function() {return m(Overlay, {element: "#overlay", state: "pending"})}});
    };
    
    var showOverlay = function(state, attrs) {
        m.mount($("#overlay")[0], {view: function() {return m(Overlay, $.extend({element: "#overlay", state: state}, attrs))}});
    };
    
    var hideOverlay = function() {
        $(".overlay").detach();
        clear();
    };
    
    var submitIfNeeded = function() {
         var code = "";
        code += $("#code-1").val();
        code += $("#code-2").val();
        code += $("#code-3").val();
        code += $("#code-4").val();
        if (code.length == 4) {
            submit(code);
        }      
    };
    
    var submit = function(code) {

        clear();
        showPending();
        
        return m.request({
            method: "POST",
            url: "/api/redemption/redeem",
            body: {authorization: Credentials.getToken("REDEMPTION_TOKEN"), data: {code: code}}
        }).then(function(data) {
            showOverlay("approved", {amount: data.amount});
        }).catch(function(error) {
            if (error.code === 401) {
                authenticate();
                hideOverlay();
            } else {
                var message = "";
                if (error.response.hasOwnProperty("unredeemable") ) {
                    error.response.unredeemable.forEach(function(e) {
                        message += e;
                    });
                }
                showOverlay("denied", {reason: message});
                shake($(".overlay"));
            }
        });
        

    };
    
    
    var clearInput = function(index) {
        var input = $("#code-"+index);
        input.val("");
    };
    
    var decrInputIndex = function() {
        var currentIndex = inputIndex;
        if (currentIndex > 1) {
            var currentInput = $("#code-" + currentIndex);
            inputIndex = currentIndex - 1;
            var prevInput = $("#code-" + inputIndex);
            currentInput.toggleClass("focus");
            prevInput.toggleClass("focus");
        }
    };
    
    var incrInputIndex = function() {
        if (inputIndex < 4) {
            var index = inputIndex + 1;
            var previousInput = $("#code-" + inputIndex);
            inputIndex = index;
            var nextInput = $("#code-" + inputIndex);
            previousInput.toggleClass("focus");
            nextInput.toggleClass("focus");
        }
    };
    
    var numberpadPress = function(ev) {
        var number = $(ev.target).closest(".number").data("value");
        console.log($(ev.target).closest(".number"));
        if (number == "bs") {
            decrInputIndex();
            clearInput(inputIndex);
        } else if ($.isNumeric(number)) {
            var input = $("#code-"+inputIndex);
            input.val(number);
            incrInputIndex();
            submitIfNeeded();
        }
    };
    
    var mount = function() {
        if (!Credentials.hasToken("REDEMPTION_TOKEN")) {
            authenticate();
        }
        
        $("td.number-pad.number").click(numberpadPress);
    
        clear();
        $("#code-1").prop("disabled", true);
        $("#code-2").prop("disabled", true);
        $("#code-3").prop("disabled", true);
        $("#code-4").prop("disabled", true);
        
        loadMerchantData();
        
    };
    
    
    return {mount: mount};
})();