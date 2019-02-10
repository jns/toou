/* global $, m */

var Modal = (function() {
    
    var setTitle = function(title) {
        $('.modal-title').html(title);
    };
    
    var setBody = function(body) {
        if (body.hasOwnProperty('view')) {
            m.mount($('.modal-body')[0], body);
        } else {
            $('.modal-body').html(body);
        }
    };
    
    var setDismissalButton = function(buttonText) {
        $('.modal-footer > button').html(buttonText);
    };
    
    var show = function(completion) {
        $('#modal').modal('show');
        $('#modal').on('hidden.bs.modal',function(e) { 
            console.log("Closed Modal");
            completion();
            $('#modal').off('hidden.bs.modal');   
        });
    };
    
    var dismiss = function() {
        $('#modal').modal('hide');
    }
    
    return {show: show, dismiss: dismiss, setTitle: setTitle, setBody: setBody, setDismissalButton: setDismissalButton};
})();