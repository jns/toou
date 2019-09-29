/* global $, m */

var Modal = (function() {
    
    var _body = null;
    var _bodyAttr = null;
    var _afterOk = null;
    
    var setTitle = function(title) {
        $('.modal-title').html(title);
    };
    
    var getBody = function() { return _body; };
    
    /**
     * Body is expected to be a standard mithril component with standard lifecycle
     * methods such as oninit and view.  
     * @param attr is passed into body lifecycle calls as vnode.attr
     * 
     * If body has an okClicked function, then that is called when the modal ok button is clicked.
     * okClicked is expected to return a Promise that resolves to a value that is passed to the 
     * the completion handler for the ok button.
     */
    var setBody = function(body, attr) {
        
        m.mount($(".modal-body")[0], null);
        _body = body;
        
        if (body.hasOwnProperty('view')) {
            $(".modal-body").html("");
            if (attr == undefined) {
                _bodyAttr = {};
            } else {
                _bodyAttr = attr;
            }
            
            m.mount($('.modal-body')[0], {view: function(){ return m(body, _bodyAttr)}});
        } else {
            $('.modal-body').html(body);
        }
        
        if (body.hasOwnProperty('okText')) {
            setOkButton(body.okText, function() {});
        }
        if (body.hasOwnProperty('cancelText')) {
            setCancelButton(body.cancelText, function() {});
        }
    };
    
    var setOkButton = function(buttonText, completion) {
        
        var button = $('.modal-footer > .ok-button');
        button.off("click");
        if (typeof buttonText !== undefined && buttonText !== null) {
            button.html(buttonText);
            button.click(function() {
                disableOkButton();
                if (_body.hasOwnProperty("okClicked")) {
                    _body.okClicked().then(function(result){
                        completion(result); 
                    }).then(function(result) {
                        if (typeof _afterOk === 'function') { _afterOk(); }
                    }).catch(function(error) {
                        setBody(_body, $.extend(_bodyAttr, error));
                        enableOkButton();
                    });
                } else {
                    new Promise(function(resolve, reject) {
                        resolve(completion());
                    }).then(function(result){
                        if (typeof _afterOk === 'function') { _afterOk(); }
                    });
                }
            }); // invoke completion handler with modal body as argument
            button.show();
            enableOkButton();
        } else {
            button.hide();
            disableOkButton();
        }    
    };
    
    var setCancelButton = function(buttonText, completion) {
        var button = $('.modal-footer > .cancel-button');
        button.off("click");
        if (typeof buttonText !== undefined && buttonText !== null) {
            button.html(buttonText);
            button.click(function() {
                if (_body.hasOwnProperty("cancelClicked")) {
                    _body.cancelClicked().then(function(result){
                        completion(result); 
                    });
                } else {
                    completion();
                }
            });
            button.show();
        } else {
            button.hide();
        }
    };
    
    
    var show = function(completion) {
        
        $('#modal').modal('show');
        $('#modal').on('hidden.bs.modal',function(e) { 
            $('#modal').off('hidden.bs.modal');
            if (typeof completion === 'function') {
                completion();
            }
            $('modal-footer > .cancel-button').off('onclick');
            $('modal-footer > .ok-button').off('onclick');
        });
    };
    
    var dismiss = function() {
        $('#modal').modal('hide');
    };
    
    var disableOkButton = function() {
        $('.modal-footer > .ok-button').prop('disabled', true);
    };
    
    var enableOkButton = function () {
        $('.modal-footer > .ok-button').prop('disabled', false);
    };
    
    var afterOk = function(completion) {
        _afterOk = completion;    
    };
    
    return {show: show, dismiss: dismiss, 
            setTitle: setTitle, 
            setBody: setBody, 
            setOkButton: setOkButton, 
            disableOkButton: disableOkButton,
            enableOkButton: enableOkButton,
            setCancelButton: setCancelButton,
            getBody: getBody,
            afterOk: afterOk,
    };
})();