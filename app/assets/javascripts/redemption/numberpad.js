var NumberPad = function(clickHandler) {
  
    var numberpadPress = function(ev) {
        var number = $(ev.target).closest(".number").data("value");
        if (typeof clickHandler == "function") {
            clickHandler(number);
        }
    };

  
    this.view = function() {
        return m("table.number-pad", 
            m("tbody", [
                m("tr.trow", [
                    m("td.number-pad.number", {"data-value": 1, onclick: numberpadPress}, 1),
                    m("td.number-pad.number", {"data-value": 2, onclick: numberpadPress}, 2),
                    m("td.number-pad.number", {"data-value": 3, onclick: numberpadPress}, 3),
                    ]),
                m("tr.trow", [
                    m("td.number-pad.number", {"data-value": 4, onclick: numberpadPress}, 4),
                    m("td.number-pad.number", {"data-value": 5, onclick: numberpadPress}, 5),
                    m("td.number-pad.number", {"data-value": 6, onclick: numberpadPress}, 6),
                    ]),
                m("tr.trow", [
                    m("td.number-pad.number", {"data-value": 7, onclick: numberpadPress}, 7),
                    m("td.number-pad.number", {"data-value": 8, onclick: numberpadPress}, 8),
                    m("td.number-pad.number", {"data-value": 9, onclick: numberpadPress}, 9),
                    ]),
                m("tr.trow", [
                    m("td.number-pad.number.backspace", {"data-value": "bs", onclick: numberpadPress}, m("i.fa.fa-backspace")),
                    m("td.number-pad.number", {"data-value": 0, onclick: numberpadPress}, 0),
                    m("td.number-pad"),
                    ]),
            ])
        );

    };
};