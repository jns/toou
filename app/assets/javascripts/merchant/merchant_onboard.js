/* global m */
var MerchantAddressForm = (function() {
    
    var data = {};
    
    var view = function(vnode) {
        var merchant_name = "";
        var formatted_addr = "";
        var international_phone = "";
        var website = "https://";
        
        if (vnode.attrs.place) {
            merchant_name = vnode.attrs.place.name;
            formatted_addr = vnode.attrs.place.formatted_address;
            international_phone = vnode.attrs.place.international_phone_number;
            website = vnode.attrs.place.website;
        }
        
        return m("form", [
            m(".form-group", [
                m("label", {for: "merchant_name"}, "Establishment Name"),
                m("input.form-control", {type: "text", name: "merchant_name", value: merchant_name}),
                m("label", {for: "merchant_address"}, "Address"),
                m("input.form-control", {type: "text", name: "merchant_address", value: formatted_addr}),
                m("label", {for: "merchant_phone"}, "Phone"),
                m("input.form-control", {type: "text", name: "merchant_phone", value: international_phone}),
                m("label", {for: "merchant_website"}, "Website"),
                m("input.form-control", {type: "text", name: "merchant_website", value: website}),
                ]),
            m(".form-group"),
            ]
        )
    };
    
    return {view: view, data: data};
})()

var MerchantOnboard = (function() {
    
    
    var mount = function() {
        var components = [MerchantAutocomplete, MerchantAddressForm, ];
        var wizard = Modal2(components);
        m.mount(document.getElementById("merchant_onboard"), wizard)
    }
    
    return {mount: mount};
})();