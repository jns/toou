//= require_directory ./merchant

var Merchants = (function() {
    
    var mount = function(path) {
        var root = $('#MerchantsContent')[0];
        if (path.match(/onboard/)) {
            m.mount(root, MerchantOnboardWorkflow); 
        } else {
            m.mount(root, MerchantEnrollment); 
        }
    };
    
    return {mount: mount}
})();