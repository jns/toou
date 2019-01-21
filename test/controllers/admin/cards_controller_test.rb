require 'test_helper'

class Admin::CardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_card = cards(:one)
    password = "a password"
    acct = admin_accounts(:admin)
    acct.password = password
    acct.save
    post admin_authenticate_url, params: {username: "admin", password: password}
  end

  test "should get index" do
    get admin_cards_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_card_url
    assert_response :success
  end

  test "should create admin_card" do
    assert_difference('Card.count') do
      post admin_cards_url, params: { card: { pan: "1234 1234 1234 1234", expiration: "2023/01/01", cvc: "123" } }
    end

    assert_redirected_to admin_card_url(Card.last)
  end

  test "should show admin_card" do
    @session
      get admin_card_url(@admin_card)
      assert_response :success
  end

  test "should get edit" do
    get edit_admin_card_url(@admin_card)
    assert_response :success
  end

  test "should update admin_card" do
    patch admin_card_url(@admin_card), params: { card: { cvc: "111" } }
    assert_redirected_to admin_card_url(@admin_card)
  end

  test "should destroy admin_card" do
    assert_difference('Card.count', -1) do
      delete admin_card_url(@admin_card)
    end

    assert_redirected_to admin_cards_url
  end
  
end
