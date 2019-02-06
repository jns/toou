
var Goodbye = (function() { 
    var view;
    view = function() {
        return m("a", {href: "#!/hello"}, "Goodbye World! " + Credentials.getPhoneNumber());
    };
    
    return {view: view};
})();
