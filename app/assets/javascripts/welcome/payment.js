/* global $, m, Stripe, Credentials */

var Payment = (function() {
    
    var stripe = Stripe('pk_test_0H9zeU0MikaqcvxovYGpV1pp');
    
    var createPaymentRequest = function(buyable) {
        console.log("Creating payment request for " + buyable.name);
        var pr = stripe.paymentRequest({
          country: 'US',
          currency: 'usd',
          total: {
            label: buyable.name,
            amount: buyable.max_price_cents,
          },
          requestPayerName: true,
          requestPayerEmail: true,
          requestPayerPhone: true
        });
        
        pr.on("token", function(event) {
            console.log("processing token");
            processPayment(buyable, event).then(function(response) {
                    console.log(response);
                    event.complete('success');
                    console.log("Purchase successful");
                    completePurchase();
                }).catch(function(err) {
                    event.complete('fail');
                    console.log("Purchase failed");
                    console.log(err);
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
        $('#modal').modal('show');
        $('#modal').on('hidden.bs.modal',function(e) { 
            console.log("Closed Modal");
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