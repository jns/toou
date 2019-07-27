/* global $, Credentials , m, Routes */
var MerchantInfo = (function() {
    var merchantName = "";
    var merchantAddress = "";
    
    var oninit = function() {
        if (Credentials.hasToken("REDEMPTION_TOKEN")) {
            m.request({
                method: "POST",
                body: {authorization: Credentials.getToken("REDEMPTION_TOKEN")},
                url: "/api/redemption/merchant_info"
            }).then(function(merchantData) {
               merchantName = merchantData.name;
               merchantAddress = merchantData.address;
            }).catch(function(error) {
                if (error.code === 401) {
                    Credentials.setToken();
                }
            });
        }
    };
    
    var view = function() {
        return m(".text-center", [m(".h3", merchantName), m(".h6", merchantAddress)]);    
    };
    
    return {view: view, oninit: oninit};    
})();

var RedeemToou = (function() {
    
    var shake = function(element) {
        element.animate({paddingLeft: "-=10px"}, 100)
            .animate({paddingLeft: "+=20px"}, 100)
            .animate({paddingLeft: "-=20px"}, 100)
            .animate({paddingLeft: "+=20px"}, 100)
            .animate({paddingLeft: "-=20px"}, 100)
            .animate({paddingLeft: "+=10px"}, 100);
    };
    
    var clear = function() {
        $("#code-1").val("");
        $("#code-2").val("");
        $("#code-3").val("");
        $("#code-4").val("");
        $("#code-1").focus();
    }
    
    var showPending = function() {
        var pending = $("<div>Pending</div>").addClass("overlay").addClass("pending");
        $("#redemption").prepend(pending);
    }
    
    var showOverlay = function(text, state) {
        $(".pending").detach();
        var overlay = $('<div></div>').addClass("overlay").addClass(state).html(text);
        overlay.click(hideOverlay);
        $("#redemption").prepend(overlay);
    }
    
    var hideOverlay = function() {
        $(".overlay").detach()
        clear()
    }
    
    var submit = function() {
        var code = ""
        code += $("#code-1").val();
        code += $("#code-2").val();
        code += $("#code-3").val();
        code += $("#code-4").val();
        
        $("#code-4").blur();
        
        showPending();
        
        return m.request({
            method: "POST",
            url: "/api/redemption/redeem",
            body: {authorization: Credentials.getToken("REDEMPTION_TOKEN"), data: {code: code}}
        }).then(function(data) {
            showOverlay("<div>Approved</div><div>"+data.amount+"</div>", "approved");
        }).catch(function(error) {
            if (error.code === 401) {
                Routes.goRedeemLogin();
            } else {
                var message = "<div>Denied</div>";
                if (error.response.hasOwnProperty("unredeemable") ) {
                    error.response.unredeemable.forEach(function(e) {
                        message += "<div class=\"small\">"+e+"</div>";
                    });
                }
                showOverlay(message, "denied");
                shake($(".overlay"));
            }
        });
        

    };
    
    var next = function(index) {
        var input = $("#code-"+index);
        var value = input.val();
        if ($.isNumeric(value) && value.length == 1) {
            if (index === 4) {
                submit();
            } else {
                var incr = index+1;
                $("#code-"+incr).focus();
            }
        } else {
            input.val("");
        }
    };
    
    var prev = function(ev, index) {
        if (ev.keyCode === 8) {
            var decr = index-1;
            var box = $("#code-"+decr);
            box.val("");
            box.focus();
        }
    };
    
    var clearInput = function(index) {
        var input = $("#code-"+index);
        input.val("");
    };
    
    var mount = function() {
        if (!Credentials.hasToken("REDEMPTION_TOKEN")) {
            Routes.deviceNotAuthorized();
            return;
        }
        
        m.mount($(".merchant-info")[0], MerchantInfo);
        
        $("#code-1").focus(function() {clearInput(1)});
        $("#code-2").focus(function() {clearInput(2)});
        $("#code-3").focus(function() {clearInput(3)});
        $("#code-4").focus(function() {clearInput(4)});
        
        $("#code-2").keydown(function(ev) {prev(ev, 2)});
        $("#code-3").keydown(function(ev) {prev(ev, 3)});
        $("#code-4").keydown(function(ev) {prev(ev, 4)});
        
        $("#code-1").keyup(function() {next(1)});
        $("#code-2").keyup(function() {next(2)});
        $("#code-3").keyup(function() {next(3)});
        $("#code-4").keyup(function() {next(4)});
        
        $("#code-1").focus();
    };
    
    return {mount: mount};
})();