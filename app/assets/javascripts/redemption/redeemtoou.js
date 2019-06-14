/* global $, Credentials , m, Routes */
var MerchantInfo = (function() {
    var merchantName = "";
    
    var oninit = function() {
        m.request({
            method: "POST",
            body: {auth_token: Credentials.getToken()},
            url: "/api/redemption/merchant_info"
        }).then(function(merchantData) {
           merchantName = merchantData.name;
        });
    };
    
    var view = function() {
        return m(".span.h3", merchantName);    
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
            body: {auth_token: Credentials.getToken(), code: code}
        }).then(function(data) {
            showOverlay("<div>Approved</div><div>"+data.amount+"</div>", "approved");
        }).catch(function(error) {
            if (error.code === 401) {
                Routes.goRedeemLogin();
            } else {
                showOverlay("Denied", "denied");
                shake($(".overlay"))
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
        if (!Credentials.hasToken()) {
            Routes.goRedeemLogin();
            return;
        }
        
        $(".signout").click(signout);
        
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
    
    var signout = function() {
        Credentials.setToken();
        Routes.goRedeemLogin();
    };
    
    return {mount: mount, signout: signout};
})();