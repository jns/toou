var Dispatcher = (function() {

    var topics = {SIGNIN: "", SIGNOUT: ""};
    var routes = [];

    var register = function (topic, action) {
        if (typeof action === 'function') {
            routes.push({ topic: topic, action: action });
            return this;
        } else {
            throw new Error("Action must be a function");
        }
    };

    var dispatch = function (topic, data) {
        routes.forEach(function(route) {
            if (topic === route.topic) {
              route.action(data);
            }
        })
    };

    return {register: register, dispatch: dispatch, topics: topics};

})();