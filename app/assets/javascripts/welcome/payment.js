/* global $, m, Stripe, Credentials, Modal */

var Payment = (function() {
    
    var stripe
    var toou_fee = 100; // $1 to send
    
    fetch("/keys/stripe_key").then(function(response) {
        return response.json();    
    }).then(function(data) { 
        stripe = Stripe(data["stripe_public_api_key"]);
    });
    
    var createPaymentRequest = function(buyable) {
        var pr = stripe.paymentRequest({
          country: 'US',
          currency: 'usd',
          total: {
            label: buyable.name,
            amount: buyable.max_price_cents + toou_fee,
          },
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
                purchaser: {
                    name: event.payerName,
                    email: event.payerEmail,
                    phone: event.payerPhone,
                },
                recipients: [document.getElementById('recipient_phone').value],
                message: "Test Message",
                payment_source: event.token.id,
                product: {
                    id: buyable.id,
                    type: buyable.type
                }
           };
        return m.request({
            method: "POST",
            url: "/api/order",
            data: payload,
            headers: Credentials.getAuthHeader()
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
    }
    
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
                $('#payment-request-button').text("Add a payment method to your browser to purchase.")
                // var card = elements.create('card');
                // card.mount('#payment-request-button');
            }
        });
    }
    
    var setBuyable = function(buyable) {
        var paymentRequest = createPaymentRequest(buyable);
        addPaymentButton(paymentRequest);
    }
    
    return {setBuyable: setBuyable};
    
})();