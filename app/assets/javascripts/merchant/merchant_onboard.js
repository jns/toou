/* global m */

var MerchantOnboardWorkflow = (function() {

    var workflow = Modal2([MerchantAutocomplete, MerchantAddressForm, MerchantProducts, AuthorizeDevice]);
    workflow.oncomplete = function(result, err) {
        console.log(result);    
    };
    
    var view = function(vnode) {
        if (!Credentials.isUserLoggedIn()) {
            return m(MerchantEnrollment);
        } else {
            return m(workflow);
        }
    };

    return {view: view};
})();

var MerchantOnboard = (function() {
    
    var mount = function() {
        m.mount(document.getElementById("merchant_onboard"), MerchantOnboardWorkflow);
    }
    
    return {mount: mount};
})();