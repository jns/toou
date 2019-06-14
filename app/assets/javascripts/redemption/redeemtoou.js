/* global $ */
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
        console.log(code);
        
        $("#code-4").blur();
        clear();
        
        showPending();
        setTimeout(function() {
            $(".pending").detach();
            if (code == "0000") {
                showOverlay("<div>Approved</div><div>$10</div>", "approved");
            } else {
                showOverlay("Denied", "denied");
                shake($(".overlay"))
            }            
        }, 1000);
        

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
    
    var clearInput = function(index) {
        var input = $("#code-"+index);
        input.val("");
    }
    
    var mount = function() {
        $("#code-1").focus(function() {clearInput(1)});
        $("#code-2").focus(function() {clearInput(2)});
        $("#code-3").focus(function() {clearInput(3)});
        $("#code-4").focus(function() {clearInput(4)});
        
        $("#code-1").keyup(function() {next(1)});
        $("#code-2").keyup(function() {next(2)});
        $("#code-3").keyup(function() {next(3)});
        $("#code-4").keyup(function() {next(4)});
    };
    return {mount: mount, shake: shake};
})();