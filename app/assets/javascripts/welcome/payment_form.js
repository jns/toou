/* global $, m, Stripe, Credentials, Modal, Routes */

var PaymentForm = (function() { 
    
    var userData = null;
    var stripe = null;
    var cardElement = null;
    var paymentMethods = [];
     
    var oninit = function(vnode) {
        
        stripe = vnode.attrs.stripe;

        Credentials.getUserData().then(function(data) {
            userData = data;
        });
        
        
        m.request("/api/payment_methods", {
            method: "POST", 
            body: {authorization: Credentials.getToken()}
        }).then(function(data) {
            if (data.length > 0) {
                paymentMethods = data;
            } else {
                createCardElement();
            }
        }).catch(function() {
            createCardElement();
        });
    };
    
    var onupdate = function() {
        if (document.getElementById("card-input") && cardElement) {
            cardElement.mount('#card-input');
        }
    };
    
    var createCardElement = function() {

        // Remove other payment methods
        // paymentMethods.length = 0;
        
        cardElement = stripe.elements().create('card');

        cardElement.addEventListener('change', function(event) {
          var displayError = document.getElementById('card-errors');
          if (event.error) {
            displayError.textContent = event.error.message;
          } else {
            displayError.textContent = '';
          }
        });
    };
    
    var cardInput = function() {
        if (paymentMethods == undefined ) {
            return m("[id=card-input]");
        } else if (paymentMethods.length > 1) { 
            var options = paymentMethods.map(function(pm) {
                var card = pm["card"];
                return m("option", {value: pm["id"]}, card["brand"] + " " + card["last4"]);
            });
            return m("[id=card-input]", m(".row.form-group", [
                                            m("label.col", "Payment Method"), 
                                            m("select.col.form-control.form-control-sm", options), 
                                            m(".btn.btn-sm", {onclick: createCardElement}, "New card")]));
        } else if (paymentMethods.length == 1) {
            var pm = paymentMethods[0];
            var card = pm["card"];
            return m("[id=card-input]", m(".row.form-group", [
                                            m("label.col", "Payment Method"), 
                                            m("input.col.text-center[type=text][readonly][id="+pm.id+"][value="+card.brand + " *" + card.last4+"]"), 
                                            m(".btn.btn-sm", {onclick: createCardElement}, "New card")]));
        } else {
            return m("[id=card-input]");
        }
    };
    
    var payerInputs = function() {

        var inputs = [];
        if (userData != undefined && userData.name != undefined) {
            inputs.push(m('.row.form-group',[ m('label.col', "Your name"), m('input.col.form-control[id=payer-name][type=text][value='+userData.name+']')]));
        } else {
            inputs.push(m('.row.form-group',[ m('label.col', "Your name"), m('input.col.form-control[id=payer-name][type=text]')]));
        }
        
        if (userData != undefined && userData.phone != undefined) {
            inputs.push(m('.row.form-group',[ m('label.col', "Your Mobile Phone"), m('input.col.form-control[id=payer-phone][type=text][value='+userData.phone+']')]));
        } else {
            inputs.push(m('.row.form-group',[ m('label.col', "Your Mobile Phone"), m('input.col.form-control[id=payer-phone][type=text]')]));
        }
        
        
        if (userData != undefined && userData.email != undefined) {
            inputs.push(m('.row.form-group',[ m('label.col', "Your email"), m('input.col.form-control[id=payer-email][type=text][value='+userData.email+']')]));
        } else {
            inputs.push(m('.row.form-group',[ m('label.col', "Your email"), m('input.col.form-control[id=payer-email][type=text]')]));
        }
       return inputs;

    };
    
    /**
     * Determines whether a new card or a saved card was entered, and provides that
     */
    var createPaymentMethod = function() {
        if (document.getElementById("card-input")) {
            if (paymentMethods.length > 1) {
                var method= paymentMethods[$("#card-input select").prop("selectedIndex")];
                return new Promise(function(resolve, reject) {
                    resolve(Object.assign({paymentMethod: method}, payerData()));   
                });
            } else if (paymentMethods.length == 1) {
                var method = paymentMethods[0];
                return new Promise(function(resolve, reject) {
                    resolve(Object.assign({paymentMethod: method}, payerData()));
                });
            } else {
                return new Promise(function(resolve, reject) {
                    stripe.createPaymentMethod('card', cardElement).then(function(method) {
                       resolve(Object.assign(method, payerData()));
                    }).catch(function() {
                       resolve(payerData()); 
                    });
                });
            }
        } else {
            return new Promise(function(resolve, reject) {
                resolve(payerData());
            });
        }
    };
    
    var view = function(vnode) {
        var buyable = vnode.attrs.buyable;
    
        var formElements =  [
                m('.row.form-group',[m('label.col', buyable.name), m('label.col', "$"+ buyable.max_price_dollars)]),
                m('.row.form-group',[m('label.col', "TooU Fee"), m('label.col', "$" + buyable.fee_dollars)]),
                m('.row.form-group',[m('label.col', "Total"), m('label.col', "$"+ (buyable.max_price_dollars + buyable.fee_dollars))]),
                payerInputs(),
            ];
        
        if ((buyable.max_price_dollars + buyable.fee_dollars) > 0) {
            formElements.push(cardInput(), m('.row[id=card-errors]'));  
        } 
        
        return m('form.container.form', formElements);
    };
    
    var payerData =function() {
        return { 
            payerName: $('#payer-name').val(),
            payerPhone: $('#payer-phone').val(),
            payerEmail: $('#payer-email').val(),
        };
    };
    
    return {view: view, oninit: oninit, onupdate: onupdate, payerData: payerData, okClicked: createPaymentMethod};
    
})();
