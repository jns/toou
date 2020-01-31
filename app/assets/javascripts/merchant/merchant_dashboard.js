/* glboal Credentials, m */
var MerchantDashboard = function() {
    
    var merchantDashboardStyle = ".merchant-dashboard { margin: 1em 2em 1em 2em; }";
    var onboardWorkflow = new MerchantOnboardWorkflow();
    
    var oninit = function(vnode) {
        var styleSheet = document.createElement("style");
        styleSheet.type = "text/css";
        styleSheet.innerText = merchantDashboardStyle;
        document.head.appendChild(styleSheet);
    }

    
    var view = function() {
        if (Credentials.isUserLoggedIn()) {
            return [m(".h4.text-center", "Merchant Dashboard"), 
                    m(".merchant-dashboard", m(MerchantBusinesses))];
        } else {
            return m(MerchantLogin);
        }
    };
    
    return {view: view, oninit: oninit};
}