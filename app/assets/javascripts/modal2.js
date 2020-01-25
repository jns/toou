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


/**
 * Constructs a mithril component that displays a series of Tasks in succession.
 * The component automatically advances between tasks when the Task calls it's own
 * complete(result) function. The contents of result are passed to the next
 * Task via vnode.attrs
 * 
 * At the completion of the final Task, this component invokes it's own complete(result) 
 * function, where result is the aggregation of all the data from the individual Tasks.
 */
var Modal2 = function(tasks) {
    
    var data = {};
    var unstagedComponents = [];
    var task = Object.create(Task);
    
    tasks.forEach(function(c, i) {
        c.state = "staged";
        c.oncomplete = function(result, err) {
            if (err === null || typeof err == 'undefined') {
               Object.assign(data, result);
               advance();
            } else {
                console.log(err);
            }
        }
    });
    tasks[0].state = "active";


    var activeComponent = function() {
        return tasks.find(function(c) { return c.state == "active";});
    };
    
    var onDeck = function() {
        return tasks.find(function(c) { return c.state == "staged"; });
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
        var activeIndex = tasks.findIndex(function(c) { return c.state == "active";});
        var first = activeIndex === 0;
        var last = activeIndex === (tasks.length-1);
        
        var comps = tasks.map(function(c) { return m(".wiz-item."+c.state, m(c, data))});
        var dots = tasks.map(function(c) { return m("span.dot" + (c.state == "active" ? ".filled" : ""));});
        return m(".wiz", [m(".wiz-items", comps), 
                         m(".wiz-control", [
                            //  m("input.btn.btn-light.previous" + (first ? ".invisible" : ".visible"), {type: "button", onclick: previous, value: "Back"}),
                             m(".dots", dots),
                            //  m("input.btn.btn-light.next" + (last ? ".invisible" :  ".visible"), {type: "button", onclick: advance, value: "Next"}),
                             ])]);
    };
    
    
    return task;
    
};