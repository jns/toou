var MerchantDashboard = function() {
    
    var view = function() {
        if (Credentials.isUserLoggedIn()) {
            return m(".h4.text-center", "Merchant Dashboard");
        } else {
            return m(MerchantLogin);
        }
    };
    
    return {view: view};
}