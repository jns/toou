/* global $, m, Stripe, Credentials, Modal, Routes */

var PaymentForm = { 
    
    userData: null,
    buyable: null,
    stripe: null,
    cardElement: null,
    paymentMethods: null,
    paymentMethodInput: null,
    
    oninit: function() {
        
        Credentials.getUserData().then(function(data) {
            PaymentForm.userData = data;
        });
        
        m.request("/api/payment_methods", {
            method: "POST", 
            body: {authorization: Credentials.getToken()}
        }).then(function(data) {
            if (data.length > 0) {
                PaymentForm.paymentMethods = data;
            } else {
                PaymentForm.createCardElement();
            }
        }).catch(function(data) {
            PaymentForm.createCardElement();
        });
    },
    
    
    createCardElement: function() {
        $.get("/keys/stripe_key", function(data) {
            
            $("#card-input").removeClass();
            PaymentForm.stripe = Stripe(data["stripe_public_api_key"]);
           
            PaymentForm.cardElement = PaymentForm.stripe.elements().create('card');
            PaymentForm.cardElement.mount('#card-input');

            PaymentForm.cardElement.addEventListener('change', function(event) {
              var displayError = document.getElementById('card-errors');
              if (event.error) {
                displayError.textContent = event.error.message;
              } else {
                displayError.textContent = '';
              }
            });
        });
    },
    
    cardInput: function() {
        if (this.paymentMethods == undefined ) {
            this.paymentMethodInput = "new";
            return m("[id=card-input]");
        } else if (this.paymentMethods.length > 1) { 
            this.paymentMethodInput = "select";
            var options = this.paymentMethods.map(function(pm) {
                var card = pm["card"];
                return m("option", {value: pm["id"]}, card["brand"] + " " + card["last4"]);
            });
            return m(".row.form-group[id=card-input]", [m("label.col", "Payment Method"), 
                                         m("select.col.form-control.form-control-sm", options), 
                                         m(".btn.btn-sm", {onclick: PaymentForm.createCardElement}, "New card")]);
        } else if (this.paymentMethods.length == 1) {
            this.paymentMethodInput = "single";
            var pm = this.paymentMethods[0];
            var card = pm["card"];
            return m(".row.form-group[id=card-input]", [m("label.col", "Payment Method"), 
                                                        m("input.col.text-center[type=text][readonly][id="+pm.id+"][value="+card.brand + " *" + card.last4+"]"), 
                                                        m(".btn.btn-sm", {onclick: PaymentForm.createCardElement}, "New card")]);
        } else {
            this.paymentMethodInput = "new";
            return m("[id=card-input]");
        }
    },
    
    payerInputs: function() {

        var inputs = [];
        if (this.userData != undefined && this.userData["name"] != undefined) {
            inputs.push(m('.row.form-group',[ m('label.col', "Your name"), m('input.col.form-control[id=payer-name][type=text][value='+this.userData["name"]+']')]));
        } else {
            inputs.push(m('.row.form-group',[ m('label.col', "Your name"), m('input.col.form-control[id=payer-name][type=text]')]));
        }
        
        if (this.userData != undefined && this.userData["phone"] != undefined) {
            inputs.push(m('.row.form-group',[ m('label.col', "Your Mobile Phone"), m('input.col.form-control[id=payer-phone][type=text][value='+this.userData["phone"]+']')]));
        } else {
            inputs.push(m('.row.form-group',[ m('label.col', "Your Mobile Phone"), m('input.col.form-control[id=payer-phone][type=text]')]));
        }
        
        
        if (this.userData != undefined && this.userData["email"] != undefined) {
            inputs.push(m('.row.form-group',[ m('label.col', "Your email"), m('input.col.form-control[id=payer-email][type=text][value='+this.userData["email"]+']')]));
        } else {
            inputs.push(m('.row.form-group',[ m('label.col', "Your email"), m('input.col.form-control[id=payer-email][type=text]')]));
        }
       return inputs;

    },
    
    /**
     * Determines whether a new card or a saved card was entered, and provides that
     */
    createPaymentMethod: function() {    
        if (this.paymentMethodInput == "select") {
            var method= this.paymentMethods[$("#card-input select").prop("selectedIndex")];
            return new Promise(function(resolve, reject) {
                resolve({paymentMethod: method});   
            });
        } else if (this.paymentMethodInput == "single") {
            var method = this.paymentMethods[0];
            return new Promise(function(resolve, reject) {
                resolve({paymentMethod: method});
            });
        } else {
            return this.stripe.createPaymentMethod('card', this.cardElement);
        }
    },

    view: function() {
        console.log(this.userData);
        return m('form.container.form', [
            m('.row.form-group',[m('label.col', this.buyable.name), m('label.col', "$"+this.buyable.max_price_dollars)]),
            m('.row.form-group',[m('label.col', "TooU Fee"), m('label.col', "$1.25")]),
            m('.row.form-group',[m('label.col', "Total"), m('label.col', "$"+ (this.buyable.max_price_dollars + 1.25))]),
            this.payerInputs(),
            this.cardInput(),
            m('.row[id=card-errors]'),
            ]);  
    },
    
    payerData: function() {
        return { 
            payerName: $('#payer-name').val(),
            payerPhone: $('#payer-phone').val(),
            payerEmail: $('#payer-email').val(),
        };
    }
};

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
       console.log(payerData);
       var  payload = {
                authorization: Credentials.getToken(),
                purchaser: {
                    name: payerData.payerName,
                    email: payerData.payerEmail,
                    phone: payerData.payerPhone,
                },
                recipients: [document.getElementById('recipient_phone').value],
                message: document.getElementById('message_input').value,
                payment_source: payerData.paymentMethod.id,
                product: {
                    id: buyable.id,
                    type: buyable.type
                }
           };
        m.request({
            method: "POST",
            url: "/api/initiate_order",
            body: payload
        }).then(function(response) {
            handleServerResponse(response);
        }).catch(function(err) {
            if (err.code == 401) {
                Modal.setBody("Authenticating...");
                authenticate(payerData).then(function() {
                    processPayment(buyable, payerData);
                }).catch(function(err) {
                    purchaseFailed(err);
                });
            } else {
                purchaseFailed(JSON.stringify(err));
            }
       });
    };
    
    var authenticate = function(payerData) {
        
        Credentials.phone_number = payerData.payerPhone;
        
        return new Promise(function(resolve, reject) {
            m.request("/api/requestOneTimePasscode", {
                method: "POST",
                body: {phone_number: payerData.payerPhone,
                        name: payerData.payerName,
                        email: payerData.payerEmail}
            }).then(function(response) {
                Modal.setTitle("Enter Passcode to Confirm Identity");
                Modal.setBody(OneTimePasscode);
                Modal.setOkButton("Submit", passcodeAuthentication);
                Modal.setCancelButton("Cancel", cancelPurchase);
            }).catch(function(err) {
                reject(err);
            });
        });
    };
    
    var passcodeAuthentication = function() {
        Credentials.authenticate(Credentials.phone_number, Credentials.passcode).then(function() {
            Modal.dismiss();
        })
        
    };
    
    var handleServerResponse = function(response) {
        var requires_action = response["requires_action"];
            
        if (requires_action === "auth_and_confirm") {
            console.log("auth_and_confirm");
        } else if (requires_action === "confirm") {
            console.log("confirm");
            confirmPayment(response["payment_intent_client_secret"])
        } else if (response["success"]) {
            completePurchase();
        } else {
            purchaseFailed("Ugh. ");
        }
    };
    
    var authenticateAndConfirmPurchase = function() {
        // Set token
        confirmPayment(client_secret)
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
              purchaseFailed("");
            } else {
                // The card action has been handled
                // The PaymentIntent can be confirmed again on the server
                fetch('/ajax/confirm_payment', {
                    method: 'POST',
                    headers: {
                      'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({payment_intent_id: result.paymentIntent.id})
                }).then(function(confirmResult) {
                    handleServerResponse(confirmResult.json());
                });
            }
        });
    };
    
    var paymentFormPurchaseAction = function(){ 
        Modal.disableOkButton();
        PaymentForm.createPaymentMethod().then(function(result) {
            if (result.error) {
              // Inform the customer that there was an error.
              var errorElement = document.getElementById('payment-errors');
              errorElement.textContent = result.error.message;
              Modal.enableOkButton();
            } else {
              // Send the token to your server.
              var payerData = PaymentForm.payerData();
              payerData.paymentMethod = result.paymentMethod;
              processPayment(payerData);
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
                PaymentForm.buyable = buyable;
                Modal.setBody(PaymentForm);
                Modal.setCancelButton("Not Now", Modal.dismiss);
                Modal.setOkButton("Buy", paymentFormPurchaseAction);
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