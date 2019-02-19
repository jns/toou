require 'test_helper'

class PromotionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @draft_promotion = promotions(:draft)
    @active_promotion = promotions(:active)
    @password = "a password"
    @acct = users(:admin_user)
    @acct.password = @password
    @acct.save
  end

  teardown do
    reset!
  end

  test "should get index if authenticated" do
    post login_url, params: {user: {username: @acct.username, password: @password}}
    get promotions_url
    assert_response :success
  end

  test "should get new if authenticated" do
    post login_url, params: {user: {username: @acct.username, password: @password}}
    get new_promotion_url
    assert_response :success
  end

  test "should create promotion if authenticated" do
    post login_url, params: {user: {username: @acct.username, password: @password}}
    assert_difference('Promotion.count') do
      post promotions_url, params: { promotion: { copy: @draft_promotion.copy, end_date: @draft_promotion.end_date, name: @draft_promotion.name, product: @draft_promotion.product, price_cents: @draft_promotion.price_cents } }
    end

    assert_redirected_to promotion_url(Promotion.last)
  end

  test "should show draft promotion if authenticated" do
    post login_url, params: {user: {username: @acct.username, password: @password}}
    get promotion_url(@draft_promotion)
    assert_response :success
  end

  test "should get edit for draft promotion if authenticated" do
    post login_url, params: {user: {username: @acct.username, password: @password}}
    get edit_promotion_url(@draft_promotion)
    assert_response :success
  end

  test "should update draft promotion if authenticated" do
    post login_url, params: {user: {username: @acct.username, password: @password}}
    patch promotion_url(@draft_promotion), params: { promotion: { copy: @draft_promotion.copy, end_date: @draft_promotion.end_date, image_url: @draft_promotion.image_url, name: @draft_promotion.name, product: @draft_promotion.product } }
    assert_redirected_to promotion_url(@draft_promotion)
  end

  test "should destroy draft promotion if authenticated" do
    post login_url, params: {user: {username: @acct.username, password: @password}}
    assert_difference('Promotion.count', -1) do
      delete promotion_url(@draft_promotion)
    end

    assert_redirected_to promotions_url
  end
end
