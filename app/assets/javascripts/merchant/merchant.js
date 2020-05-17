/* global m */
var Merchant = function() {
    
    var stripe_link = null;
    
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
    this.products = [];

    this.formattedAddress = function() {
        return [this.address1, this.address2, this.city + ",", this.state, this.zip, this.country].join(" ");  
    };
    
    /** Returns a promise that resolves to a URL for a stripe dashboard or enrollment link */
    this.stripeLink = function() {
        var mid = this.merchant_id;
                
        return new Promise(function(resolve, reject) {
            if (stripe_link) {
                resolve(stripe_link);
            } else {
                m.request({url: "/api/merchant/stripe_link", 
                            method: "POST",
                            body: {authorization: Credentials.getUserToken(), 
                                    data: {merchant_id: mid}}})
                .then(function(data) {
                    stripe_link = data;
                    resolve(stripe_link);
                }).catch(function(err) {
                    stripe_link = "Error retrieving Stripe Link";
                    reject(err);
                });
            }
        });
    }
    
    var findAddressComponent = function(name, fields) {
        var field = fields.find(function(f) {
           return (f.types.indexOf(name) > -1);
        });
        return (field ? field.short_name : null);
    };
    
    this.addOrUpdate = function() {
        var url = null;
        var method = null;
        if (this.merchant_id == null) {
            url = "/api/merchant/create";
            method = "POST";
        } else {
            url = "/api/merchant";
            method = "PUT";
        }
        
        var data = {merchant_id: this.merchant_id,
                    name: this.name,
                    phone_number: this.phone_number,
                    website: this.website,
                    address1: this.address1,
                    address2: this.address2,
                    city: this.city,
                    state: this.state,
                    zip: this.zip,
                    country: this.country,
                    latitude: this.latitude,
                    longitude: this.longitude};
                    
        return m.request({url: url, method: method, body: {authorization: Credentials.getUserToken(), data: data}})
            .then((data) => {
                Object.assign(this, data);
            });
    };
    
    this.updateProducts = function() {
        
        var data = {merchant_id: this.merchant_id}
        data.products = this.products.map(function(p) {
           return {id: p.id, can_redeem: p.can_redeem, price_cents: p.max_price_cents};
        });

        var method = null;
        if (data.length == 0) {
            method = "POST"; // no products to update, retreive only
        } else {
            method = "PUT";
        }

        return m.request({
                url: "/api/merchant/products", 
                method: method, 
                body: {authorization: Credentials.getUserToken(), data: data}})
            .then((result) => { this.products = result});
    };
    
    
    this.initialize = function(data) {
        this.merchant_id = data.merchant_id;
        this.name = data.name;
        this.phone_number = data.phone_number;
        this.website = data.website;
        this.address1 = data.address1;
        this.address2 = data.address2;
        this.city = data.city;
        this.state = data.state;
        this.zip = data.zip;
        this.country = data.country;
        this.products = data.products;
    }
    
    this.initializeFromGooglePlace = function(data) {
        if (data.name) { this.name = data.name };
        if (data.international_phone_number) { this.phone_number = data.international_phone_number; }
        if (data.website) { this.website = data.website; }
        if (data.address_components) {
            var subpremise = findAddressComponent("subpremise", data.address_components);
            
            this.address1 = findAddressComponent("street_number", data.address_components) + 
                                           " " + findAddressComponent("route", data.address_components) + 
                                           (subpremise ? " " + subpremise : "");
            this.city = findAddressComponent("locality", data.address_components);
            this.state = findAddressComponent("administrative_area_level_1", data.address_components);
            this.zip = findAddressComponent("postal_code", data.address_components);
            this.country = findAddressComponent("country", data.address_components);
        }
        
        if (data.geometry) {
            var lat = data.geometry.location.lat;
            var lng = data.geometry.location.lng;
            
            this.latitude = (typeof lat == 'function' ? lat() : lat);
            this.longitude = (typeof lng == 'function' ? lng() : lng);
        }
    };
    
}