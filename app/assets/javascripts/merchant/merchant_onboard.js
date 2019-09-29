var MerchantOnboard = (function() {
    
    var step1 = function() {
        var title = m(".m5", "Step 1 of 3");
        return [title, MerchantAutocomplete]
    }
    
    var mount = function() {
        m.mount($("#merchant_onboard")[0], MerchantAutocomplete)
    }
    
    return {mount: mount};
})();