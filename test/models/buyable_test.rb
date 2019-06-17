require 'test_helper'

class BuyableTest < ActiveSupport::TestCase

    test "Product is buyable" do
        product = products(:beer)
        assert product.respond_to? :id
        assert product.respond_to? :name
        assert product.respond_to? :icon
        assert product.respond_to? :price
    end
    
    test "Promotion is buyable" do
        promo = promotions(:active)
        assert promo.respond_to? :id
        assert promo.respond_to? :name
        assert promo.respond_to? :icon
        assert promo.respond_to? :price
    end

end