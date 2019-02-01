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
    
fetchPromotions = ->
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

completePurchase = ->
    $('#exampleModal').modal('show')
    $('#exampleModal').on 'hidden.bs.modal', (e) -> 
        host = window.location.host
        window.location = "dashboard"
 
loadPromos = ->
    console.log("Loading Promos")
    fetchPromotions().then (promos) -> 
        stripe = Stripe('pk_test_0H9zeU0MikaqcvxovYGpV1pp');
        promo = promos[0]
        populatePromoCard(promo)
        pr = createPaymentRequest(stripe, promo)
        addPaymentButton(stripe, pr)
        pr.on 'token', (event) -> 
            processPayment(promo, event).then (response) ->
                if response.ok
                    event.complete('success')
                    completePurchase()
                else
                    event.complete('fail')    
                    showErrors(response.json())

showPasses = ->
    login.hide()
    passes.show()
    passes.updatePasses()
    
class Credentials
    
    constructor: (auth_callback) ->
        @auth_callback = auth_callback
    
    getAuthToken: () ->
        localStorage.getItem('auth_token')
        
    setAuthToken: (token) ->
        localStorage.setItem('auth_token', token)
        @auth_callback() if auth_token?
        
    hasAuthToken: ->
        localStorage.getItem('auth_token')?

class Widget

    objectReplace: (element, object) -> 
        element.find "[data-property]"
        .each (i, d) ->
            attr = d.attributes["data-property"]
            if attr?
                val = object
                props = attr.value.split "."
                val = val[props.shift()] while props.length > 0
                d.innerHTML = val
            
    collectionReplace: (element, collection) ->
        dataElement = element.find("[data-each]")
        html = dataElement.html()
        dataElement.empty()
        for obj in collection
            objHtml = $(html)
            objEl = objHtml.appendTo(dataElement)
            @objectReplace(objEl, obj)
            

class PassesWidget extends Widget

    passes: "#Passes"
    credentials: null
    
    constructor: (credentials) ->
        @credentials = credentials
    
    initialize: ->
        $(@passes + " .refresh-link").on 'click', () => @updatePasses()
        
    hide: ->
        $(@passes).hide()
        
    show: ->
        $(@passes).show()
    
    updatePasses: ->
        @fetchPasses().then (passes) =>
            @collectionReplace($(@passes), passes)
                
    
    fetchPasses: ->
        fetch '/api/passes', 
            method: 'POST'
            headers: 
                "content-type": "application/json" 
                "Authorization": "Bearer #{@credentials.getAuthToken()}"
            body: '{"serialNumbers": "[]"}'
        .then (response) ->
            response.json()

class LoginWidget
    
    loginForm: "#Login"
    otpForm: "#OneTimePasscode"
    credentials: null
    
    
    constructor: (credentials) ->
        @credentials = credentials 
        
    initialize: ->
        @hide()
        
        $(@loginForm).on "ajax:success", (e, data, status, xhr) =>
            console.log(data)
            @validPhone()
            @showOneTimePasscode()
        .on "ajax:error", (e, xhr, status, error) =>
            @invalidPhone()
    
        $(@otpForm).on "ajax:success", (e, data, status, xhr) =>
            @credentials.setAuthToken(data.auth_token)
            @hide()
        .on "ajax:error", (e, xhr, status, error) =>
            @invalidOTP()
        
    showLogin: ->
        $(@loginForm).show()
    
    showOneTimePasscode: ->
        $(@otpForm).show()
    
    hide: ->
        $(@otpForm).hide()
        $(@loginForm).hide()
        
    validPhone: ->
        phoneInput = $(@loginForm).find('[name=phone_number]')
        phoneInput.removeClass('is-invalid')
        phoneInput.addClass('is-valid')
        $('<input>').attr 
            type: 'hidden'
            name: 'phone_number'
            value: phoneInput.val()
        .appendTo(@otpForm + " > form")
        
    invalidPhone: ->
         $(@loginForm).find('[name=phone_number]').addClass("is-invalid")
    
    invalidOTP: ->
        $(@otpForm).find('[name=pass_code]').addClass("is-invalid")


credentials = new Credentials(showPasses)
login = new LoginWidget(credentials)
passes = new PassesWidget(credentials)

loadDashboard = () ->
    login.initialize()
    passes.initialize()
    if credentials.hasAuthToken()
        passes.updatePasses()
    else
        login.showLogin()
        
$(document).on "turbolinks:load",  ->
    loadPromos() if window.location.pathname == "/promos"
    loadDashboard() if window.location.pathname == "/dashboard"
    