require 'test_helper'

class RedemptionControllerTest < ActionDispatch::IntegrationTest

  def setup 
      
  end 
  
  test "Group member can redeem" do
    
    account = accounts(:active_duty)
    token = forceAuthenticate(account)
    pass = passes(:redeemable_by_army)
    
    merchant = merchants(:quantum)
    post api_redemption_get_code_url, params: {authorization: token, data: {merchant_id: merchant.id, pass_sn: pass.serial_number}}
    assert_response :ok
    json = JSON.parse(@response.body)
    code = json["code"]
    assert code
    
    token = getRedemptionToken(merchant)
    post api_redemption_redeem_url, params: {authorization: token, data: { code: code}}
    assert_response :ok
    
    
  end 
  
  def getRedemptionToken(merchant)
      device = merchant.authorize_device("Device")
      command = CreateRedemptionAuthToken.call(device)
      return command.result
  end
end
