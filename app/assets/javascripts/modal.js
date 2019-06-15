/* global $, m */

var Modal = (function() {
    
    
    var setTitle = function(title) {
        $('.modal-title').html(title);
    };
    
    var setBody = function(body) {
        
        m.mount($(".modal-body")[0], null);
        
        if (body.hasOwnProperty('view')) {
            $(".modal-body").html("");
            m.mount($('.modal-body')[0], body);
        } else {
            $('.modal-body').html(body);
        }
    };
    
    var setOkButton = function(buttonText, completion) {
        var button = $('.modal-footer > .ok-button');
        if (typeof buttonText !== undefined && buttonText !== null) {
            button.html(buttonText);
            button.click(completion);
            button.show();
        } else {
            button.hide();
        }    
    };
    
    var setCancelButton = function(buttonText, completion) {
        var button = $('.modal-footer > .cancel-button');
        if (typeof buttonText !== undefined && buttonText !== null) {
            button.html(buttonText);
            button.click(completion);
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
    }
    
    return {show: show, dismiss: dismiss, setTitle: setTitle, setBody: setBody, setOkButton: setOkButton, setCancelButton: setCancelButton};
})();