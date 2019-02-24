require 'test_helper'

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should post ephemeral_keys" do
    mock_key = Minitest::Mock.new
    mock_key.expect :to_json, "a.mock.ephemeral.key"
    
    a = accounts(:josh)
    token = forceAuthenticate(a)
    
    # the post method should call Stripe::EphemeralKey and return a key in the json
    Stripe::EphemeralKey.stub :create, mock_key do
      post payments_ephemeral_keys_url, params: {authorization: token, data: {"api_version": "1"}}, as: :json
      assert_response :success
      assert_equal response.body, "a.mock.ephemeral.key"
    end
    assert_mock mock_key

  end

end
