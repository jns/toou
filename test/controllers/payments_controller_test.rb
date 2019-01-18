require 'test_helper'

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should post ephemeral_keys" do
    mock_key = Minitest::Mock.new
    mock_key.expect :to_json, "a.mock.ephemeral.key"
    
    a = accounts(:josh)
    token = forceAuthenticate(a)
    
    # the post method should call Stripe::EphemeralKey and return a key in the json
    Stripe::EphemeralKey.stub :create, mock_key do
      post payments_ephemeral_keys_url, params: {'api_version': "1"}, headers: {"Authorization": "Bearer #{token}"}, as: :json
      assert_response :success
      assert_equal response.body, "a.mock.ephemeral.key"
    end
    assert_mock mock_key

  end

  test "should post charge" do
    mock_charge = Minitest::Mock.new
    mock_charge.expect :id, "12345"
    
    a = accounts(:josh)
    token = forceAuthenticate(a)
    
    Stripe::Charge.stub :create, mock_charge do
      post payments_charge_url, params: {"amount": 10.0, "source": "VISA"}, headers: {"Authorization": "Bearer #{token}"}, as: :json
      assert_response :success
      assert_equal JSON.parse(response.body)["charge_identifier"], "12345"
    end
    assert_mock mock_charge
  end

end
