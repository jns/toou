//= require ./merchant_autocomplete
//= require ./merchant_address_form
//= require ./merchant_products
//= require ./authorize_device

/* global m */

var MerchantOnboardWorkflow = (function() {

    var workflow = Modal2([MerchantAutocomplete, MerchantAddressForm, MerchantProducts, AuthorizeDevice]);
    workflow.oncomplete = function(result, err) {
        console.log(result);    
    };
    
    var view = function(vnode) {
        if (!Credentials.isUserLoggedIn()) {
            return m(MerchantLogin);
        } else {
            return m(workflow);
        }
    };

    return {view: view};
})();
