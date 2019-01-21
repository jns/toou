require 'test_helper'

class Admin::CardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_card = admin_cards(:one)
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
    assert_difference('Admin::Card.count') do
      post admin_cards_url, params: { admin_card: {  } }
    end

    assert_redirected_to admin_card_url(Admin::Card.last)
  end

  test "should show admin_card" do
    get admin_card_url(@admin_card)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_card_url(@admin_card)
    assert_response :success
  end

  test "should update admin_card" do
    patch admin_card_url(@admin_card), params: { admin_card: {  } }
    assert_redirected_to admin_card_url(@admin_card)
  end

  test "should destroy admin_card" do
    assert_difference('Admin::Card.count', -1) do
      delete admin_card_url(@admin_card)
    end

    assert_redirected_to admin_cards_url
  end
end
