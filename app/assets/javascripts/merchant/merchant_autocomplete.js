/* global $, m,s uuidv4 */
var MerchantAutocomplete = (function() {

    var token = uuidv4();
    var key = "AIzaSyAbmo8M4MHl7hPMvXyxsdW3BC_hATcZ3Bk";
    var data = {};
    
    var oncreate = function() {
        createAutocomplete();
    }
    
    var createAutocomplete = function() {
        
        
        var element = document.getElementById('autocomplete');
        var country = $("#country_select").val();

        if (element) {
           var autocomplete = new google.maps.places.Autocomplete(element, 
                {   types: ['establishment'], 
                    componentRestrictions: {country: country} });
           google.maps.event.addListener(autocomplete, 'place_changed', onPlaceChanged);
        }
    }

    var onPlaceChanged = function() {
         var place = this.getPlace();     
         data.place = place;
         console.log(place);  
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
        return [m(".row",
                        m(".col", [
                                m("label", {for: "country_select"}, "Country"),
                                m("select.form-control[name=country_select][id=country_select]", {onchange: createAutocomplete}, [m("option", {value: "us"}, "🇺🇸 United States"), m("option", {value: "au"}, "🇦🇺Australia")]),
                            ]
                        )
                    ),
                    m(".row",
                        m(".col", [
                            m("label", {for: "autocomplete"}, "Search for your business"),
                            m("input.form-control[name=autocomplete][id='autocomplete']", {placeholder: "Business Name"}),
                            ]
                        )
                    ),   
            ];
    };
    
    return {view: view, oncreate: oncreate, data: data};
})();
