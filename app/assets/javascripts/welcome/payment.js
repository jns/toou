/* global $, m, Stripe, Credentials, Modal */

var PaymentForm = { 
    
    stripe: null,
    card: null,
    
    oninit: function() {
 
        $.get("/keys/stripe_key", function(data) { 
            PaymentForm.stripe = Stripe(data["stripe_public_api_key"]);
           
            PaymentForm.card = PaymentForm.stripe.elements().create('card');
            PaymentForm.card.mount('#card-input');
        
            PaymentForm.card.addEventListener('change', function(event) {
              var displayError = document.getElementById('card-errors');
              if (event.error) {
                displayError.textContent = event.error.message;
              } else {
                displayError.textContent = '';
              }
            });
                 
        });
    },
    
    createToken: function() {        
      return this.stripe.createToken(this.card);
    },

    view: function() {
        return m('form.container.form', [
            m('.row.form-group',[ m('label.col', "name"), m('input.col.form-control[id=payer-name][type=text]')]),
            m('.row.form-group',[ m('label.col', "phone"), m('input.col.form-control[id=payer-phone][type=text]')]),
            m('.row.form-group',[ m('label.col', "email"), m('input.col.form-control[id=payer-email][type=text]')]),
            m('[id=card-input]'),
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
    
    var stripe
    
    $.get("/keys/stripe_key", function(data) { 
        stripe = Stripe(data["stripe_public_api_key"]);
    });
    
    var createPaymentRequest = function(buyable) {
        var pr = stripe.paymentRequest({
          country: 'US',
          currency: 'usd',
          total: {label: "Total", amount: buyable.max_price_cents, pending: false},
          displayItems: [
              {label: buyable.name, amount: buyable.max_price_cents,pending: true}
          ],
          requestPayerName: true,
          requestPayerEmail: true,
          requestPayerPhone: true
        });
        
        pr.on("token", function(event) {
            console.log("processing token");
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
       var  payload = {
                authorization: Credentials.getToken(),
                purchaser: {
                    name: event.payerName,
                    email: event.payerEmail,
                    phone: event.payerPhone,
                },
                recipients: [document.getElementById('recipient_phone').value],
                message: document.getElementById('message_input').value,
                payment_source: event.token.id,
                product: {
                    id: buyable.id,
                    type: buyable.type
                }
           };
        return m.request({
            method: "POST",
            url: "/api/order",
            data: payload
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
                Modal.setBody(PaymentForm);
                Modal.setCancelButton("Not Now", function(){ Modal.hide(); });
                Modal.setOkButton("Buy", function(){ 
                    PaymentForm.createToken().then(function(result) {
                        if (result.error) {
                          // Inform the customer that there was an error.
                          var errorElement = document.getElementById('payment-errors');
                          errorElement.textContent = result.error.message;
                        } else {
                          // Send the token to your server.
                          var data = PaymentForm.payerData();
                          data.token = result.token;
                          processPayment(buyable, data).then(function(response) {
                                completePurchase();
                            }).catch(function(err) {
                                purchaseFailed(err);
                           });
                        }
                  });
                });
                var button = $('<button class="btn btn-primary">').text("Send Now").click(function() { 
                    Modal.show();
                });
                $('#payment-request-button').append(button);
            }
        });
    };
    
    var setBuyable = function(buyable) {
        var paymentRequest = createPaymentRequest(buyable);
        addPaymentButton(paymentRequest, buyable);
    };
    
    return {setBuyable: setBuyable};
    
})();