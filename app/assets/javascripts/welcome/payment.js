/* global $, m, Stripe, Credentials, Modal, Routes, OneTimePasscode */

var Payment = (function() {
    
    var buyable;
    var stripe;
    var recipient;
    
    $.get("/keys/stripe_key", function(data) { 
        stripe = Stripe(data["stripe_public_api_key"]);
    });
    
    
    // Payment Intent Process
    var createPaymentIntent = function() {
 
        
        var pr = stripe.paymentRequest({
          country: 'US',
          currency: 'usd',
          total: {label: "Total", amount: buyable.max_price_cents + buyable.fee_cents, pending: false},
          displayItems: [
              {label: buyable.name, amount: buyable.max_price_cents,pending: false},
              {label: "Sending Fee", amount: buyable.fee_cents, pending: false}
          ],
          requestPayerName: true,
          requestPayerEmail: true,
          requestPayerPhone: true
        });
        
        pr.on("paymentmethod", function(event) {
            submitPayment(event, "initiate_order").then(function(response) {
                    event.complete('success');
                    completePurchase();
                }).catch(function(err) {
                    event.complete('fail');
                    purchaseFailed(err.response.error);
               });
            });
    
        return pr;
    };
    
    var submitPayment = function(payerData, api) {
        var  payload = {
                purchaser: {
                    phone: payerData.payerPhone,
                    name: payerData.payerName,
                    email: payerData.payerEmail,
                }, 
                authorization: Credentials.getToken(),
                recipients: [recipient],
                message: document.getElementById('message_input').value,
                product: {
                    id: buyable.id,
                    type: buyable.type
                }
           };

        if (payerData.hasOwnProperty('paymentMethod')) {
            payload.payment_source = payerData.paymentMethod.id;
        } else if (payerData.hasOwnProperty('token')) {
            payload.payment_source = payerData.token.id;
        } else if ((buyable.fee_cents + buyable.max_price_cents) == 0) {
            payload.payment_source = "none";
        } else {
            return new Promise(function(resolve, reject) {
                reject({response: {error:  "Missing Payment Method"}});
            });
        }

        return m.request({
            method: "POST",
            url: "/api/" + api,
            body: payload
        });  
    };
    
    var processPayment = function(payerData) {

        Modal.setTitle("Just a sec...");
        Modal.setBody('<div class=\"purchase-animation\"><img /><div>');
        $('.purchase-animation img')[0].src = window.toouAssets.purchase_in_progress_img;
        submitPayment(payerData, "initiate_order").then(function(response) {
            handleServerResponse(response);
        }).catch(function(err) {
            if (err.code == 401) {
                Modal.setBody("Authenticating...");
                authenticate(payerData);
            } else {
                purchaseFailed(err.response.error);
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
                resolve();
            }).catch(function(err) {
                reject(err.response.error);
            });
        });
    };
    
    
    var handleServerResponse = function(response) {
        if (response["requires_action"]) {
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
        Modal.setBody("<div class=\"purchase-animation\"><img /></div><div class=\"text-center\">We've sent the TooU</div>");
        $(".purchase-animation img")[0].src = window.toouAssets.purchase_success_img;
        Modal.setOkButton("Ok", Routes.goHome);
        Modal.setCancelButton(null);
        Modal.show();
    };
    
    var purchaseFailed = function(err) {
        Modal.setTitle("Whoops");
        Modal.setBody("<div class=\"purchase-animation\"><img /></div><div class=\"text-center\">There was a problem with the purchase.<p/>" + err + "</div>");
        $(".purchase-animation img")[0].src = window.toouAssets.purchase_failed_img;
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
                   purchaseFailed("Payment Failed"); 
                });
            }
        });
    };
    
    var createPaymentForm = function(buttonText) {
        // Payment API is not supported.  
        // Fallback to a payment form
        Modal.setTitle("Payment Information");
        Modal.setBody(PaymentForm, {stripe: stripe, buyable: buyable});
        Modal.setCancelButton("Not Now", Modal.dismiss);
        Modal.setOkButton(buttonText, processPayment);
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
            }
        });
        
        createPaymentForm("Buy");
        var button = $('<button class="btn btn-primary">').text("Pay with Credit Card").click(function() { 
            Modal.show();
        });
        $('#alternate-payment-button').html(button);
    };
    
    var addFreePaymentButton = function() {
        createPaymentForm("Send for Free");
        var button = $('<button class="btn btn-primary">').text("Send for free").click(function() {
            Modal.show();
        });
        $('#payment-request-button').empty();
        $("#alternate-payment-button").html(button);
    };
    
    var setBuyable = function(b) {
        buyable = b;
        if ((buyable.max_price_cents + buyable.fee_cents) > 0) {
            var paymentRequest = createPaymentIntent();
            addPaymentButton(paymentRequest);
        } else {
            addFreePaymentButton();
        }
    };
    
    var setRecipient = function(r) {
        recipient = r;
    }
    
    return {setBuyable: setBuyable, setRecipient: setRecipient};
    
})();