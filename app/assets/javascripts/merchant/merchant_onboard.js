/* global m */

var MerchantOnboard = (function() {
    
    
    var mount = function() {
        var components = [MerchantAutocomplete, MerchantAddressForm, MerchantProducts, AuthorizedDevices];
        var wizard = Modal2(components);
        m.mount(document.getElementById("merchant_onboard"), wizard)
    }
    
    return {mount: mount};
})();