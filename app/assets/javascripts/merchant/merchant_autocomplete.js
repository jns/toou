/* global $, m, google */
var MerchantAutocomplete = (function() {

    // The Component will be a Task object that 
    // invokes the oncomplete callback upon finishing
    // its work.
    var task = Object.create(Task);
    
    task.oncreate = function() {
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
         var m = new Merchant();
         m.initializeFromGooglePlace(place);
         task.complete({merchant: m}, null);
    };

    task.view = function(vnode) {
        return [m(".row", 
                    m(".col.h4.text-center", "Search for Establishment")
                ),  
                m(".row",
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
    
    return task;
})();
