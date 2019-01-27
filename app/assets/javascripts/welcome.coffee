# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

createPaymentRequest = (stripe, promotion) ->
    stripe.paymentRequest({
          country: 'US',
          currency: 'usd',
          total: {
            label: promotion.name,
            amount: promotion.value_cents,
          },
          requestPayerName: true,
          requestPayerEmail: true,
          requestPayerPhone: true
        })

addPaymentButton = (stripe, paymentRequest) ->
    elements = stripe.elements();
    prButton = elements.create 'paymentRequestButton', 
        paymentRequest: paymentRequest, 
        style: 
            paymentRequestButton:
               type: 'buy'
               theme: 'dark'
    paymentRequest.canMakePayment().then (result) -> 
        if result? 
            prButton.mount('#payment-request-button') 
        else
            $("#payment-request-button").html( "Your Browser Does Not Support Apple or Google Pay")

   
processPayment = (promo, event) ->
    payload = 
        purchaser:
            name: event.payerName
            email: event.payerEmail
            phone: event.payerPhone
        recipients: [document.getElementById('recipient_phone').value]
        message: ""
        payment_source: event.token.id
        promotion_id: promo.id
    fetch('/api/order', 
        method: 'POST'
        body: JSON.stringify(payload)
        headers: {'content-type': 'application/json'})

showErrors = (errors) ->
    console.log(errors)
    $('#payment_errors').show()
    $('#recipient_phone').addClass('is-invalid')
    
fetchPromotions = () ->
    fetch('/api/promotions', 
        method: 'GET'
        headers: {'content-type': 'application/json'})
    .then (response) ->
        response.json() 
    
populatePromoCard = (promotion) ->
    console.log(promotion)
    $('#promotion_name').html(promotion.name)
    $('#promotion_copy').html(promotion.copy)
    $('#promotion_value_dollars').html(promotion.value_dollars)
    $('#promotion_product').html(promotion.product)
    $('#promotion_end_date').html(promotion.end_date)
    $('#promotion_qty_left').html(promotion.qty_remaining)

$(document).ready ->
    stripe = Stripe('pk_test_0H9zeU0MikaqcvxovYGpV1pp');
    fetchPromotions().then (promos) -> 
        promo = promos[0]
        populatePromoCard(promo)
        pr = createPaymentRequest(stripe, promo)
        addPaymentButton(stripe, pr)
        pr.on 'token', (event) -> 
            processPayment(promo, event).then (response) ->
                if response.ok
                    event.complete('success')
                    console.log(response.json())
                else
                    event.complete('fail')    
                    showErrors(response.json())