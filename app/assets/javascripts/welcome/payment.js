/* global $, m, Stripe, Credentials, Modal, Routes */

var PaymentForm = (function() { 
    
    var userData = null;
    var stripe = null;
    var cardElement = null;
    var paymentMethods = [];
     
    var oninit = function(vnode) {
        
        stripe = vnode.attrs.stripe;

        Credentials.getUserData().then(function(data) {
            userData = data;
        });
        
        
        m.request("/api/payment_methods", {
            method: "POST", 
            body: {authorization: Credentials.getToken()}
        }).then(function(data) {
            if (data.length > 0) {
                paymentMethods = data;
            } else {
                createCardElement();
            }
        }).catch(function(data) {
            createCardElement();
        });
    };
    
    
    var createCardElement = function() {

        // Remove other payment methods
        paymentMethods.length = 0;
        
        cardElement = stripe.elements().create('card');
        cardElement.mount('#card-input');

        cardElement.addEventListener('change', function(event) {
          var displayError = document.getElementById('card-errors');
          if (event.error) {
            displayError.textContent = event.error.message;
          } else {
            displayError.textContent = '';
          }
        });
    };
    
    var cardInput = function() {
        if (paymentMethods == undefined ) {
            return m("[id=card-input]");
        } else if (paymentMethods.length > 1) { 
            var options = paymentMethods.map(function(pm) {
                var card = pm["card"];
                return m("option", {value: pm["id"]}, card["brand"] + " " + card["last4"]);
            });
            return m("[id=card-input]", m(".row.form-group", [
                                            m("label.col", "Payment Method"), 
                                            m("select.col.form-control.form-control-sm", options), 
                                            m(".btn.btn-sm", {onclick: createCardElement}, "New card")]));
        } else if (paymentMethods.length == 1) {
            var pm = paymentMethods[0];
            var card = pm["card"];
            return m("[id=card-input]", m(".row.form-group", [
                                            m("label.col", "Payment Method"), 
                                            m("input.col.text-center[type=text][readonly][id="+pm.id+"][value="+card.brand + " *" + card.last4+"]"), 
                                            m(".btn.btn-sm", {onclick: createCardElement}, "New card")]));
        } else {
            return m("[id=card-input]");
        }
    };
    
    var payerInputs = function() {

        var inputs = [];
        if (userData != undefined && userData.name != undefined) {
            inputs.push(m('.row.form-group',[ m('label.col', "Your name"), m('input.col.form-control[id=payer-name][type=text][value='+userData.name+']')]));
        } else {
            inputs.push(m('.row.form-group',[ m('label.col', "Your name"), m('input.col.form-control[id=payer-name][type=text]')]));
        }
        
        if (userData != undefined && userData.phone != undefined) {
            inputs.push(m('.row.form-group',[ m('label.col', "Your Mobile Phone"), m('input.col.form-control[id=payer-phone][type=text][value='+userData.phone+']')]));
        } else {
            inputs.push(m('.row.form-group',[ m('label.col', "Your Mobile Phone"), m('input.col.form-control[id=payer-phone][type=text]')]));
        }
        
        
        if (userData != undefined && userData.email != undefined) {
            inputs.push(m('.row.form-group',[ m('label.col', "Your email"), m('input.col.form-control[id=payer-email][type=text][value='+userData.email+']')]));
        } else {
            inputs.push(m('.row.form-group',[ m('label.col', "Your email"), m('input.col.form-control[id=payer-email][type=text]')]));
        }
       return inputs;

    };
    
    /**
     * Determines whether a new card or a saved card was entered, and provides that
     */
    var createPaymentMethod = function() {    
        if (paymentMethods.length > 1) {
            var method= paymentMethods[$("#card-input select").prop("selectedIndex")];
            return new Promise(function(resolve, reject) {
                resolve(Object.assign({paymentMethod: method}, payerData()));   
            });
        } else if (paymentMethods.length == 1) {
            var method = paymentMethods[0];
            return new Promise(function(resolve, reject) {
                resolve(Object.assign({paymentMethod: method}, payerData()));
            });
        } else {
            return new Promise(function(resolve, reject) {
                stripe.createPaymentMethod('card', cardElement).then(function(method) {
                   resolve(Object.assign(method, payerData()));
                });
            });
        }
    };
    
    var view = function(vnode) {
        var buyable = vnode.attrs.buyable;
        return m('form.container.form', [
            m('.row.form-group',[m('label.col', buyable.name), m('label.col', "$"+ buyable.max_price_dollars)]),
            m('.row.form-group',[m('label.col', "TooU Fee"), m('label.col', "$1.25")]),
            m('.row.form-group',[m('label.col', "Total"), m('label.col', "$"+ (buyable.max_price_dollars + 1.25))]),
            payerInputs(),
            cardInput(),
            m('.row[id=card-errors]'),
            ]);  
    };
    
    var payerData =function() {
        return { 
            payerName: $('#payer-name').val(),
            payerPhone: $('#payer-phone').val(),
            payerEmail: $('#payer-email').val(),
        };
    };
    
    return {view: view, oninit: oninit, payerData: payerData, okclicked: createPaymentMethod};
    
})();

var Payment = (function() {
    
    var buyable;
    var stripe;
    
    $.get("/keys/stripe_key", function(data) { 
        stripe = Stripe(data["stripe_public_api_key"]);
    });
    
    var createPaymentIntent = function() {
 
        
        var pr = stripe.paymentRequest({
          country: 'US',
          currency: 'usd',
          total: {label: "Total", amount: buyable.max_price_cents + 125, pending: false},
          displayItems: [
              {label: buyable.name, amount: buyable.max_price_cents,pending: false},
              {label: "Sending Fee", amount: 125, pending: false}
          ],
          requestPayerName: true,
          requestPayerEmail: true,
          requestPayerPhone: true
        });
        
        pr.on("paymentmethod", function(event) {
            processPayment(event).then(function(response) {
                    event.complete('success');
                    completePurchase();
                }).catch(function(err) {
                    event.complete('fail');
                    purchaseFailed(err);
               });
            });
    
        return pr;
    };
    
    var processPayment = function(payerData) {
       var  payload = {
                authorization: Credentials.getToken(),
                recipients: [document.getElementById('recipient_phone').value],
                message: document.getElementById('message_input').value,
                payment_source: payerData.paymentMethod.id,
                product: {
                    id: buyable.id,
                    type: buyable.type
                }
           };
        Modal.setBody("Processing");
        m.request({
            method: "POST",
            url: "/api/initiate_order",
            body: payload
        }).then(function(response) {
            handleServerResponse(response);
        }).catch(function(err) {
            if (err.code == 401) {
                Modal.setBody("Authenticating...");
                authenticate(payerData);
            } else {
                purchaseFailed(JSON.stringify(err));
            }
       });
    };
    
    var authenticate = function(payerData) {
        
        return new Promise(function(resolve, reject) {
            m.request("/api/requestOneTimePasscode", {
                method: "POST",
                body: {phone_number: payerData.payerPhone,
                        name: payerData.payerName,
                        email: payerData.payerEmail}
            }).then(function(response) {
                Modal.setTitle("Enter Passcode to Confirm Identity");
                Modal.setBody(OneTimePasscode, {phone_number: payerData.payerPhone});
                Modal.setOkButton("Submit", function() { processPayment(payerData); });
                Modal.setCancelButton("Cancel", cancelPurchase);
            }).catch(function(err) {
                reject(err);
            });
        });
    };
    
    
    var handleServerResponse = function(response) {
        console.log(response);
        if (response["requires_action"]) {
            console.log("confirm");
            confirmPayment(response["payment_intent_client_secret"]);
        } else if (response["success"]) {
            completePurchase();
        } else {
            purchaseFailed("Ugh. ");
        }
    };
    
    
    var cancelPurchase = function() {
        console.log("Cancel Purchase");  
    };
    
    var completePurchase = function() {
        Modal.setTitle("Thanks");
        Modal.setBody("We've sent the TooU to " + document.getElementById('recipient_phone').value);
        Modal.setOkButton("Ok", Routes.goHome);
        Modal.setCancelButton(null);
        Modal.show();
    };
    
    var purchaseFailed = function(err) {
        Modal.setTitle("Whoops");
        Modal.setBody("Looks like there was a problem with the purchase.\n" + err);
        Modal.setOkButton("Ok", Routes.goHome);
        Modal.setCancelButton(null);
        Modal.show();
    };
    
    var cancelPurchase = function() {
        Modal.setTitle("Cancelled Purchase");
        Modal.setBody("Sorry that didn't work out.  Please try again.");
        Modal.setOkButton("Ok", Routes.goHome);
        Modal.setCancelButton(null);
        Modal.show();
    };
    
    
    var confirmPayment = function(client_secret) {
        stripe.handleCardAction(client_secret).then(function(result) {
            if (result.error) {
              // Show error in payment form
              console.log(result.error);
              purchaseFailed(result.error);
            } else {
                // The card action has been handled
                // The PaymentIntent can be confirmed again on the server
                m.request('/api/confirm_payment', {
                    method: 'POST',
                    body: {authorization: Credentials.getToken(), 
                            data: {payment_intent_id: result.paymentIntent.id}}
                }).then(function(confirmResult) {
                    handleServerResponse(confirmResult);
                }).catch(function() {
                   purchaseFailed("Confirm Payment Failed"); 
                });
            }
        });
    };
    
    var addPaymentButton = function(paymentRequest) {
        var elements = stripe.elements();
        var prButton = elements.create('paymentRequestButton', {
            paymentRequest: paymentRequest, 
            style: { paymentRequestButton: {type: 'buy', theme: 'dark'} }
        });
            
        paymentRequest.canMakePayment().then(function(result) {
           if (typeof result !== "undefined" && result !== null) {
                prButton.mount('#payment-request-button') ;
            } else {
                // Payment API is not supported.  
                // Fallback to a payment form
                Modal.setTitle("Payment Information");
                Modal.setBody(PaymentForm, {stripe: stripe, buyable: buyable});
                Modal.setCancelButton("Not Now", Modal.dismiss);
                Modal.setOkButton("Buy", processPayment);
                var button = $('<button class="btn btn-primary">').text("Send Now").click(function() { 
                    Modal.show();
                });
                $('#payment-request-button').html(button);
            }
        });
    };
    
    var setBuyable = function(b) {
        buyable = b;
        var paymentRequest = createPaymentIntent();
        addPaymentButton(paymentRequest);
    };
    
    return {setBuyable: setBuyable};
    
})();