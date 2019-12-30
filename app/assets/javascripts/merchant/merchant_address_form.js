/* global m */
var MerchantAddressForm = (function() {

    var dataStore = null;
    var formatted_address = null; // Used when dataStore is being updated.
    var addressUpdate = new Mutex();
    
    var task = Object.create(Task);

    var phoneChanged = function(ev) {
        dataStore.merchant.phone_number = $("input[name=merchant_phone]").val();
    };

    var nameChanged = function(ev) {
        dataStore.merchant.name = $("input[name=merchant_name]").val();
    };
    
    var websiteChanged = function(ev) {
        dataStore.merchant.website = $('input[name=merchant_website]').val();
    };

    var addressChanged = function(ev) {
        // lock the mutex while updating
        addressUpdate.lock();
        // cache user entered value while updating
        formatted_address = $('input[name=merchant_address]').val();

        $.get("https://maps.googleapis.com/maps/api/geocode/json", 
                {address: formatted_address, key: window.toouAssets.googleApiServerKey})
        .then(function(data) {
            if (data.results.length >= 1) {
                var result = data.results[0];
                dataStore.merchant.initializeFromGooglePlace(result);
                formatted_address = null; // Clear cached value
                addressUpdate.release();
            } 
        });
    }

    var submit = function() {
        // Perform update after google API lookup is complete
        addressUpdate.waitFor(function() {
            dataStore.merchant.addOrUpdate().then(function(data) {
                task.complete({} , null);
            }).catch(function(error) {
                alert(error);
            });
        });
    };

    task.oninit = function(vnode) {
        dataStore = vnode.attrs;  
        if (! dataStore.hasOwnProperty('merchant')) {
            dataStore.merchant = new Merchant();
        }
    };
    
    task.view = function(vnode) {
        
        var merchant_name = dataStore.merchant.name;
        var international_phone = dataStore.merchant.phone_number;
        var website = dataStore.merchant.website;
        
        // Address is cached while validating with google API. 
        var address = formatted_address;
        if (address == null) {
            address = dataStore.merchant.formattedAddress();
        }
        
        return [m(".h4.text-center", "Confirm Establishment Information"),
                m("form.overflow-auto", [
                    m(".form-group", [
                        m("label", {for: "merchant_name"}, "Establishment Name"),
                        m("input.form-control", {type: "text", name: "merchant_name", oninput: nameChanged, value: merchant_name}),
                        ]),
                    m(".form-group", [
                         m("label", {for: "merchant_address"}, "Address"),
                        m("input.form-control", {type: "text", name: "merchant_address", onchange: addressChanged, value: address}),
                       ]),
                    m(".form-group", [
                         m("label", {for: "merchant_phone"}, "Phone"),
                        m("input.form-control", {type: "text", name: "merchant_phone", oninput: phoneChanged, value: international_phone}),
                        ]),
                    m(".form-group", [
                        m("label", {for: "merchant_website"}, "Website"),
                        m("input.form-control", {type: "text", name: "merchant_website", oninput: websiteChanged, value: website}),
                       ]),
                    ],
                m(".mt-5.text-center", m("input.btn.btn-primary", {onclick: submit, value: "Confirm"}))
        )]
    };
    
    return task;
})()
