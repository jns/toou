require "application_system_test_case"

class Admin::LogsTest < ApplicationSystemTestCase
  setup do
    @admin_log = admin_logs(:one)
  end

  test "visiting the index" do
    visit admin_logs_url
    assert_selector "h1", text: "Admin/Logs"
  end

  test "creating a Log" do
    visit admin_logs_url
    click_on "New Admin/Log"

    click_on "Create Log"

    assert_text "Log was successfully created"
    click_on "Back"
  end

  test "updating a Log" do
    visit admin_logs_url
    click_on "Edit", match: :first

    click_on "Update Log"

    assert_text "Log was successfully updated"
    click_on "Back"
  end

  test "destroying a Log" do
    visit admin_logs_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Log was successfully destroyed"
  end
end
