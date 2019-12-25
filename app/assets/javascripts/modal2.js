/* global $, m */

var Modal2 = function(components) {
    components.forEach(function(c) {
        c.state = "staged";
    });
    components[0].state = "active";

    var unstagedComponents = [];
    
    var data = {};

    var oncreate = function(vnode) {
        var wizItemsHeight = 0;
        $(".wiz-item").each(function() {
           var item = $(this);
           var h = item.outerHeight();
           if (h > wizItemsHeight) { 
                wizItemsHeight = h;   
           }
        });
        console.log(wizItemsHeight)
        $(".wiz-items").css("height", wizItemsHeight);
    };

    var activeComponent = function() {
        return components.find(function(c) { return c.state == "active";});
    };
    
    var onDeck = function() {
        return components.find(function(c) { return c.state == "staged"; });
    };
    
    var previous = function() {
        var active = activeComponent();
        var lastActive = unstagedComponents.pop();
        lastActive.state = "active";
        active.state = "staged";
    };
    
    var advance = function(ev) {
        var active = activeComponent();
        var next = onDeck();
        unstagedComponents.push(active);
        active.state = "unstaged";
        next.state = "active";
        Object.assign(data, active.data);
    };

    var view = function(vnode) {
        var comps = components.map(function(c) { return m(".wiz-item."+c.state, m(c, data))});
        return m(".wiz", [m(".wiz-items", comps), 
                         m(".wiz-control", [
                             m("input.btn.btn-light.previous", {type: "button", onclick: previous, value: "Previous"}),
                             m("input.btn.btn-light.next", {type: "button", onclick: advance, value: "Next"}),
                             ])]);
    };
    
    
    return {view: view, oncreate: oncreate};
    
};