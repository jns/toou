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
            inputs.push(m('.row.form-group',[ m('label.col', "Your phone"), m('input.col.form-control[id=payer-phone][type=text][value='+this.userData["phone"]+']')]));
        } else {
            inputs.push(m('.row.form-group',[ m('label.col', "Your phone"), m('input.col.form-control[id=payer-phone][type=text]')]));
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
        if (this.paymentMethodInput == "stripe") { 
            return this.stripe.createPaymentMethod('card', this.cardElement);
        } else if (this.paymentMethodInput == "select") {
            var method= this.paymentMethods[$("#card-input select").prop("selectedIndex")];
            return new Promise(function(resolve, reject) {
                resolve({paymentMethod: method});   
            });
        } else {
            var method = this.paymentMethods[0];
            return new Promise(function(resolve, reject) {
                resolve({paymentMethod: method});
            });
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
    
    var stripe;
    
    $.get("/keys/stripe_key", function(data) { 
        stripe = Stripe(data["stripe_public_api_key"]);
    });
    
    var createPaymentIntent = function(buyable) {
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
            processPayment(buyable, event).then(function(response) {
                    event.complete('success');
                    completePurchase();
                }).catch(function(err) {
                    event.complete('fail');
                    purchaseFailed(err);
               });
            });
    
        return pr;
    };
    
    var processPayment = function(buyable, event) {
       console.log(event);
       var  payload = {
                authorization: Credentials.getToken(),
                purchaser: {
                    name: event.payerName,
                    email: event.payerEmail,
                    phone: event.payerPhone,
                },
                recipients: [document.getElementById('recipient_phone').value],
                message: document.getElementById('message_input').value,
                payment_source: event.paymentMethod.id,
                product: {
                    id: buyable.id,
                    type: buyable.type
                }
           };
        return m.request({
            method: "POST",
            url: "/api/order",
            body: payload
        });
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
    
    
    
    
    var addPaymentButton = function(paymentRequest, buyable) {
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
                Modal.setOkButton("Buy", function(){ 
                    Modal.disableOkButton();
                    PaymentForm.createPaymentMethod().then(function(result) {
                        if (result.error) {
                          // Inform the customer that there was an error.
                          var errorElement = document.getElementById('payment-errors');
                          errorElement.textContent = result.error.message;
                          Modal.enableOkButton();
                        } else {
                          // Send the token to your server.
                          var data = PaymentForm.payerData();
                          data.paymentMethod = result.paymentMethod;
                          processPayment(buyable, data).then(function(response) {
                                completePurchase();
                            }).catch(function(err) {
                                purchaseFailed(JSON.stringify(err));
                           });
                        }
                  });
                });
                var button = $('<button class="btn btn-primary">').text("Send Now").click(function() { 
                    Modal.show();
                });
                $('#payment-request-button').html(button);
            }
        });
    };
    
    var setBuyable = function(buyable) {
        var paymentRequest = createPaymentIntent(buyable);
        addPaymentButton(paymentRequest, buyable);
    };
    
    return {setBuyable: setBuyable};
    
})();