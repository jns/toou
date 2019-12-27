/* global $, m */

var Modal2 = function(components) {
    components.forEach(function(c) {
        c.state = "staged";
    });
    components[0].state = "active";

    var unstagedComponents = [];
    
    var data = {};

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
        console.log(data);
    };

    var view = function(vnode) {
        var activeIndex = components.findIndex(function(c) { return c.state == "active";});
        var first = activeIndex === 0;
        var last = activeIndex === (components.length-1);
        
        var comps = components.map(function(c) { return m(".wiz-item."+c.state, m(c, data))});
        var dots = components.map(function(c) { return m("span.dot" + (c.state == "active" ? ".filled" : ""));});
        return m(".wiz", [m(".wiz-items", comps), 
                         m(".wiz-control", [
                             m("input.btn.btn-light.previous" + (first ? ".invisible" : ".visible"), {type: "button", onclick: previous, value: "Back"}),
                             m(".dots", dots),
                             m("input.btn.btn-light.next" + (last ? ".invisible" :  ".visible"), {type: "button", onclick: advance, value: "Next"}),
                             ])]);
    };
    
    
    return {view: view};
    
};