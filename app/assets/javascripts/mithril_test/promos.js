/* global m, Stripe, Credentials, Breadcrumb $ */
    
var Promos = (function() {
    
    var stripe = Stripe('pk_test_0H9zeU0MikaqcvxovYGpV1pp');
        
    var promotions = [];
    
    var current = {}
    
    var oninit = function() {
        Breadcrumb.home();
        loadPromos();
        return null;
    };
    
    var loadPromos = function() {
        m.request({
            method: "GET",
            url: "api/promotions",
        }).then(function(data) {
            promotions = data;
            if (promotions.length > 0) {
                setPromotion(promotions[0])    
            }  
        }).catch(function(e) {
            console.log(e.message);
        });
        return null;
    }
    
    
    var completePurchase = function() {
        $('#modal').modal('show')
        $('#modal').on('hidden.bs.modal',function(e) { 
            console.log("Closed Modal")
        });
    };
    
    var setPromotion = function(promotion) {
        var paymentRequest;
        current = promotion;
        paymentRequest = createPaymentRequest(current);
        addPaymentButton(paymentRequest);
    };
                    
    var createPaymentRequest = function(promotion) {
        console.log("Creating payment request for " + promotion.name)
        var pr = stripe.paymentRequest({
          country: 'US',
          currency: 'usd',
          total: {
            label: promotion.name,
            amount: promotion.value_cents,
          },
          requestPayerName: true,
          requestPayerEmail: true,
          requestPayerPhone: true
        });
        
        pr.on("token", function(event) {
            console.log("processing token");
            processPayment(promotion, event).then(function(response) {
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
    
    var processPayment = function(promotion, event) {
       var  payload = {
                purchaser: {
                    name: event.payerName,
                    email: event.payerEmail,
                    phone: event.payerPhone,
                },
                recipients: [document.getElementById('recipient_phone').value],
                message: "Test Message",
                payment_source: event.token.id,
                promotion_id: promotion.id
           };
        return m.request({
            method: "POST",
            url: "/api/order",
            data: payload,
            headers: Credentials.getAuthHeader()
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
    
    var view = function() {
        return m(".card", [
            m(".card-header", [
                m(".promo.promo-name", m("span", current.name))
                ]),
            m(".card-body.card-text", [
                m(".promo.promo-copy", current.copy),
                m(".promo.promo-product", current.value_dollars + " for " + current.product),
                // m(".promo.promo-qty-remaining", current.qty_remaining + " left"),
                // m(".promo.promo-end-date", "Ends " + current.end_date),
                m("form.mx-auto.w-75.mt-3", [
                    m(".form-group.row", [
                        m("label.col-sm-3.col-form-label.promo", "Send This Promotion To:"),
                        m("input.form-control.col-sm-9[id=recipient_phone][type=text][placeholder='10 digit phone']"),
                        ])
                    ]),
                m(".mt-3.mx-auto.w-50[id=payment-request-button]"),
                ])
            ])
    };
    
    return {view: view, oninit: oninit}
})();