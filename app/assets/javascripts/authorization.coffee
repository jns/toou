# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
    console.log "page loaded:)"
    
    $('#redemption-code-btn').click ->
        $('#entry-point').hide(400, ()->$('#redemption-code-form').show())
        
    $('#phone-number-btn').click ->
        $('#entry-point').hide(400, ()->$('#phone-number-form').show())
    
    $('.back-to-start').click ->
        $('#redemption-code-form').hide()
        $('#phone-number-form').hide()
        $('#entry-point').show()
  