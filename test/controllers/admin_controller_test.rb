require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  
  
  
  def admin_login
    user = users(:admin_user)
    user.update(password: "password")
    post login_url, params: {user: {username: user.username, password: "password"}}
    assert_equal user.id, session[:user_id]
  end
  
  test "admin can add merchant logo" do
    admin_login
    file = fixture_file_upload(Rails.root.join('app', 'assets', 'images', 'TooULogo.png'), 'image/png')
    merchant = merchants(:cupcake_store)
    put admin_merchant_url(merchant), params: {merchant: {logo: file}}
    assert_redirected_to admin_merchant_url(merchant)
  end
end
