/* global $, m */
var Breadcrumb = function(crumbles) {
    
    var view = function(vnode) {
        var route = m.route.get();
        var crumb = crumbles.find(function(c) {
            var path_re = c["regex"];
            return path_re.test(route);
        });
        if (crumb) {
            var crumb_href = crumb["href"];
            var crumb_text = crumb["text"];
            return m(m.route.Link, {href: crumb_href}, m(".nav-breadcrumb.p-1", [m("i.fas.fa-angle-left"), m.trust("&nbsp;"), m("span.nav-breadcrumb-text", crumb_text)]));
        } else {
            return m("");
        }
    }
    
    return {view: view};
};
