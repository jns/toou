require 'test_helper'

class Admin::LogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_log = admin_logs(:one)
  end

  test "should get index" do
    get admin_logs_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_log_url
    assert_response :success
  end

  test "should create admin_log" do
    assert_difference('Admin::Log.count') do
      post admin_logs_url, params: { admin_log: {  } }
    end

    assert_redirected_to admin_log_url(Admin::Log.last)
  end

  test "should show admin_log" do
    get admin_log_url(@admin_log)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_log_url(@admin_log)
    assert_response :success
  end

  test "should update admin_log" do
    patch admin_log_url(@admin_log), params: { admin_log: {  } }
    assert_redirected_to admin_log_url(@admin_log)
  end

  test "should destroy admin_log" do
    assert_difference('Admin::Log.count', -1) do
      delete admin_log_url(@admin_log)
    end

    assert_redirected_to admin_logs_url
  end
end
