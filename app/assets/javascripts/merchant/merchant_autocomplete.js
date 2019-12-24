/* global $, m,s uuidv4 */
var MerchantAutocomplete = (function() {

    var token = uuidv4();
    var key = "AIzaSyAbmo8M4MHl7hPMvXyxsdW3BC_hATcZ3Bk";
    
    var oncreate = function() {
        var element = document.getElementById('autocomplete');
        if (element) {
           var autocomplete = new google.maps.places.Autocomplete(element, 
                {   types: ['establishment'], 
                    componentRestrictions: {country: 'us'} });
           google.maps.event.addListener(autocomplete, 'place_changed', onPlaceChanged);
        }
    }


    var onPlaceChanged = function() {
         var place = this.getPlace();     
    
         console.log(place);  // Uncomment this line to view the full object returned by Google API.     
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
                            m("input.form-control[id='autocomplete']")
            )))
    };
    
    return {view: view, oncreate: oncreate};
})();
