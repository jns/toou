require 'test_helper'

class ChargeTest < ActiveSupport::TestCase
  
  test "charges are not editable" do
    c = charges(:beer_lover_charge)
    assert_raises(Exception) { c.update(merchant: c.merchant) }
    assert_raises(Exception) { c.update(account: c.account) }
    assert_raises(Exception) { c.update(source_amount_cents: c.source_amount_cents) }
    assert_raises(Exception) { c.update(destination_amount_cents: c.destination_amount_cents) }
    assert_raises(Exception) { c.update(stripe_id: c.stripe_id) }
  end

end
