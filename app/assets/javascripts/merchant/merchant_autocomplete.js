var MerchantAutocomplete = (function() {

    var token = uuidv4();
    var key = "AIzaSyAbmo8M4MHl7hPMvXyxsdW3BC_hATcZ3Bk";
    
    var oninit = function() {
        
    }

    var autocomplete = function(e) {
        var input = e.target.value;
        
        if (input.length > 2) {
            $.get("https://maps.googleapis.com/maps/api/place/autocomplete/json?input="+input+"&key="+key+"&sessionToken="+token)
            .then(function(data) {
                console.log(data);
            })
        }
        console.log(e.target.value);
    };

    var view = function(vnode) {
        return m(".content-width", 
                    m(".row", 
                        m(".col", 
                            m("input.form-control[type='text']",
                            {
                                onkeyup: autocomplete
                            })
            )))
    };
    
    return {view: view};
})();
