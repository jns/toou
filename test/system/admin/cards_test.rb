require "application_system_test_case"

class Admin::CardsTest < ApplicationSystemTestCase
  setup do
    @admin_card = admin_cards(:one)
  end

  test "visiting the index" do
    visit admin_cards_url
    assert_selector "h1", text: "Admin/Cards"
  end

  test "creating a Card" do
    visit admin_cards_url
    click_on "New Admin/Card"

    click_on "Create Card"

    assert_text "Card was successfully created"
    click_on "Back"
  end

  test "updating a Card" do
    visit admin_cards_url
    click_on "Edit", match: :first

    click_on "Update Card"

    assert_text "Card was successfully updated"
    click_on "Back"
  end

  test "destroying a Card" do
    visit admin_cards_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Card was successfully destroyed"
  end
end
