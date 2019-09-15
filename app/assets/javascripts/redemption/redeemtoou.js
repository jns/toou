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
    
    var inputIndex = 1;
    
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
        var pending = $("<div>Pending</div>").addClass("overlay").addClass("pending");
        $("#redemption").prepend(pending);
    };
    
    var showOverlay = function(text, state) {
        $(".pending").detach();
        var overlay = $('<div></div>').addClass("overlay").addClass(state).html(text);
        overlay.click(hideOverlay);
        $("#redemption").prepend(overlay);
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
            Routes.deviceNotAuthorized();
            return;
        }
        
        $("td.number-pad.number").click(numberpadPress);
        
        m.mount($(".merchant-info")[0], MerchantInfo);
        
        clear();
        $("#code-1").prop("disabled", true);
        $("#code-2").prop("disabled", true);
        $("#code-3").prop("disabled", true);
        $("#code-4").prop("disabled", true);
        
    };
    
    
    return {mount: mount};
})();