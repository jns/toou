require 'test_helper'

class PromotionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @promotion = promotions(:not_expired)
  end

  test "should get index" do
    get promotions_url
    assert_response :success
  end

  test "should get new" do
    get new_promotion_url
    assert_response :success
  end

  test "should create promotion" do
    assert_difference('Promotion.count') do
      post promotions_url, params: { promotion: { copy: @promotion.copy, end_date: @promotion.end_date, image_url: @promotion.image_url, name: @promotion.name, product: @promotion.product, quantity: @promotion.quantity, value_cents: @promotion.value_cents } }
    end

    assert_redirected_to promotion_url(Promotion.last)
  end

  test "should show promotion" do
    get promotion_url(@promotion)
    assert_response :success
  end

  test "should get edit" do
    get edit_promotion_url(@promotion)
    assert_response :success
  end

  test "should update promotion" do
    patch promotion_url(@promotion), params: { promotion: { copy: @promotion.copy, end_date: @promotion.end_date, image_url: @promotion.image_url, name: @promotion.name, product: @promotion.product, quantity: @promotion.quantity } }
    assert_redirected_to promotion_url(@promotion)
  end

  test "should destroy promotion" do
    assert_difference('Promotion.count', -1) do
      delete promotion_url(@promotion)
    end

    assert_redirected_to promotions_url
  end
end
