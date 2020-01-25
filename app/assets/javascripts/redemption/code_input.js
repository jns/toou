var CodeInput = function() {
    
    var inputIndex = 1;
    
    this.getCode = function() {
        var code = "";
        code += $("#code-1").val();
        code += $("#code-2").val();
        code += $("#code-3").val();
        code += $("#code-4").val();
        return code;
    }
    
    this.clear = function() {
        $("#code-1").val("").removeClass("focus");
        $("#code-2").val("").removeClass("focus");
        $("#code-3").val("").removeClass("focus");
        $("#code-4").val("").removeClass("focus");
        
        inputIndex = 1;
        $("#code-1").addClass("focus");
    };
    
    /**
     * Clear current box, and move focus back one box
     */
    this.decr = function() {
        if (inputIndex > 1) {
            var input = $("#code-" + inputIndex);
            input.removeClass("focus");

            inputIndex = inputIndex - 1;
            var prevInput = $("#code-" + inputIndex);
            prevInput.val("");
            prevInput.addClass("focus");
        }
    };
    
    /**
     * Place number in the currently focused box, and move focus to the next box
     */
    this.incr = function(number) {
        if (inputIndex < 5) {
            
            var input = $("#code-" + inputIndex);
            input.removeClass("focus");
            input.val(number);
            
            inputIndex = inputIndex + 1;
            var nextInput = $("#code-" + inputIndex);
            nextInput.addClass("focus");
        } 
    };
    
    this.view = function(vnode) {
        return m(".form-group.text-center", {id: "code-input"}, [
            m("input.form-control.digit-lg.p-3.focus", {type: "number", pattern: "[0-9]", disabled: true, id: "code-1"}),
            m("input.form-control.digit-lg.p-3", {type: "number", pattern: "[0-9]", disabled: true, id: "code-2"}),
            m("input.form-control.digit-lg.p-3", {type: "number", pattern: "[0-9]", disabled: true, id: "code-3"}),
            m("input.form-control.digit-lg.p-3", {type: "number", pattern: "[0-9]", disabled: true, id: "code-4"}),
            ]);
    };
};