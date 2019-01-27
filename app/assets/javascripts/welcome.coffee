# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

processPayment = (event) ->
    payload = 
        recipients: [document.getElementById('recipient_phone').value]
        message: ""
        payment_source: event.token.id
        promotion_id: document.getElementById('promotion_id').value
    fetch('/api/place_order', 
        method: 'POST'
        body: JSON.stringify(payload)
        headers: {'content-type': 'application/json'})
    
$(document).ready ->
    stripe = Stripe('pk_test_0H9zeU0MikaqcvxovYGpV1pp');
    paymentRequest = stripe.paymentRequest({
          country: 'US',
          currency: 'usd',
          total: {
            label: 'Demo total',
            amount: 1000,
          },
          requestPayerName: true,
          requestPayerEmail: true,
          requestPayerPhone: true
        })
        
    elements = stripe.elements();
    prButton = elements.create('paymentRequestButton', {paymentRequest: paymentRequest})
    paymentRequest.canMakePayment().then (result) -> 
        if result? 
            prButton.mount('#payment-request-button') 
        else
            $("#payment-request-button").innerHTML = "Your Browser Does Not Support Apple or Google Pay"

    paymentRequest.on 'token', (event) -> 
        processPayment(event).then (response) ->
            if response.ok
                event.complete('success')
            else
                event.complete('fail')
            