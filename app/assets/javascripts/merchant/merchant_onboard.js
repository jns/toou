//= require ./merchant_autocomplete
//= require ./merchant_address_form
//= require ./merchant_products
//= require ./authorize_device

/* global m */

var MerchantOnboardWorkflow = function() {

    var workflow = new Modal2([MerchantAutocomplete, MerchantAddressForm, MerchantProducts, AuthorizeDevice]);
    workflow.oncomplete = function(result, err) {
        console.log(result);    
    };
    
    var view = function(vnode) {
        return m(workflow);
    };

    return {view: view};
};
