/* global $, m */

var Modal2 = function(components) {
    components.forEach(function(c) {
        c.state = "staged";
    });
    components[0].state = "active";
    
    var data = {};

    var oncreate = function(vnode) {
        var wizItemsHeight = "0px";
        $(".wiz-item").each(function() {
           var item = $(this);
           var h = item.css("height");
           if (h > wizItemsHeight) { 
                wizItemsHeight = h;   
           }
        });
        $(".wiz-items").css("height", wizItemsHeight);
    }

    var advance = function(ev) {
        var active = components.find(function(c) { return c.state == "active";});
        var next = components.find(function(c) { return c.state == "staged"; });
        active.state = "unstaged";
        next.state = "active";
        Object.assign(data, active.data);
    };

    var view = function(vnode) {
        var comps = components.map(function(c) { return m(".wiz-item."+c.state, m(c, data))});
        return m(".wiz", [m(".wiz-items.clearfix", comps), 
                         m(".wiz-control", [
                             m("input.btn.btn-light.text-right", {type: "button", onclick: advance, value: "Next"}),
                             ])]);
    };
    
    
    return {view: view, oncreate: oncreate};
    
};