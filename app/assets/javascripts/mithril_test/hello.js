
var Hello = { 
    view: function() {
        return m("a", {href: "#!/goodbye"}, "Hello World! " + Credentials.getPhoneNumber());
    }
}

