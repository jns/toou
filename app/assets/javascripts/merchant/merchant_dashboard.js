/* glboal Credentials, m */
var MerchantDashboard = function() {
    
    var merchantDashboardStyle = ".merchant-dashboard { margin: 1em 2em 1em 2em; }";
    var onboardWorkflow = new MerchantOnboardWorkflow();
    var userData = {email: ""};
    
    var onremove = function(vnode) {
        userData = {email: ""};
    }
    
    var oninit = function(vnode) {
        var styleSheet = document.createElement("style");
        styleSheet.type = "text/css";
        styleSheet.innerText = merchantDashboardStyle;
        document.head.appendChild(styleSheet);
        
        Credentials.getUserData().then(function(data) {
            userData = data;
            m.redraw();
        });
    }

    
    var view = function() {
        if (Credentials.isUserLoggedIn()) {
            console.log(userData.email);
            return [m(".h5.text-center", "Welcome " + userData.email), 
                    m(".merchant-dashboard", m(MerchantBusinesses))];
        } else {
            return m(MerchantLogin);
        }
    };
    
    return {view: view, oninit: oninit, onremove: onremove};
}