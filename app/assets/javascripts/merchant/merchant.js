var Merchant = function() {
    
    this.merchant_id = null;
    this.name = null;
    this.phone_number = null;
    this.website = null;
    this.address1 = null;
    this.address2 = null;
    this.city = null;
    this.state = null;
    this.zip = null;
    this.country = null;
    this.latitude = null;
    this.longitude = null;
    
    this.formatted_address = function() {
        return [this.address1, this.address2, this.city + ",", this.state, this.zip, this.country].join(" ");  
    };
    
    this.findAddressComponent = function(name, fields) {
        var field = fields.find(function(f) {
           return (f.types.indexOf(name) > -1);
        });
        return (field ? field.short_name : null);
    };
    
    this.add_or_update = function() {
        var url = null;
        var method = null;
        if (this.merchant_id == null) {
            url = "/api/merchant/create";
            method = "POST"
        } else {
            url = "/api/merchant";
            method = "PUT"
        }
        
        return m.request({url: url, method: method, body: {authorization: Credentials.getUserToken(), data: this}});
    }
    
    this.initializeFromGooglePlace = function(data) {
        if (data.name) { this.name = data.name };
        if (data.international_phone_number) { this.phone_number = data.international_phone_number; }
        if (data.website) { this.website = data.website; }
        if (data.address_components) {
            var subpremise = this.findAddressComponent("subpremise", data.address_components);
            
            this.address1 = this.findAddressComponent("street_number", data.address_components) + 
                                           " " + this.findAddressComponent("route", data.address_components) + 
                                           (subpremise ? " " + subpremise : "");
            this.city = this.findAddressComponent("locality", data.address_components);
            this.state = this.findAddressComponent("administrative_area_level_1", data.address_components);
            this.zip = this.findAddressComponent("postal_code", data.address_components);
            this.country = this.findAddressComponent("country", data.address_components);
        }
        
        if (data.geometry) {
            var lat = data.geometry.location.lat;
            var lng = data.geometry.location.lng;
            
            this.latitude = (typeof lat == 'function' ? lat() : lat);
            this.longitude = (typeof lng == 'function' ? lng() : lng);
        }
    };
    
}