/* global $, m */

/**
 * A Task is a simple interface that provides a 'complete' method
 * that is invoked by inheriting objects upon completion of their work unit.
 * complete takes two arguments, result and error that are passed to the 
 * oncomplete callback that is registered.
 */
var Task = {
    oncomplete: null,
    complete: function(result, error) {
        if (typeof this.oncomplete == 'function') {
            this.oncomplete(result, error);
        }
    }
}


var Modal2 = function(components) {
    
    var unstagedComponents = [];
    var data = {};
    var task = Object.create(Task);
    
    components.forEach(function(c, i) {
        c.state = "staged";
        c.oncomplete = function(result, err) {
            if (err === null) {
               Object.assign(data, result);
               console.log(data);
               advance();
            } else {
                console.log(err);
            }
        }
    });
    components[0].state = "active";


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
    
    var advance = function() {
        var active = activeComponent();
        var next = onDeck();
        if (typeof next == 'undefined') {
            task.complete(data, null);
            return;
        }
        unstagedComponents.push(active);
        active.state = "unstaged";
        next.state = "active";
        m.redraw();
    };

    task.view = function(vnode) {
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
    
    
    return task;
    
};