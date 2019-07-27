require 'test_helper'

class MerchantsControllerTest < ActionDispatch::IntegrationTest

   test "redirect get merchants if unauthorized" do
        get merchants_url
        assert_redirected_to login_url
    end
    
    test "redirect post merchants if unauthorized" do
        post merchants_url
        assert_redirected_to root_path
    end
    
    test "redirect get  merchant if unauthorized" do
        merchant = merchants(:quantum)
        get merchant_url(merchant)
        assert_redirected_to root_path
    end

    # test "redirect patch merchant if unauthorized" do
    #     merchant = merchants(:quantum)
    #     patch merchant_url(merchant)
    #     assert_redirected_to merchants_login_url
    # end
    
    # test "redirect put merchant if unauthorized" do
    #     merchant = merchants(:quantum)
    #     put merchant_url(merchant)
    #     assert_redirected_to merchants_login_url
    # end
    
    # test "redirect delete merchant if unauthorized" do
    #     merchant = merchants(:quantum)
    #     delete merchant_url(merchant)
    #     assert_redirected_to merchants_login_url
    # end
    
    # test "redirect 'edit' if unauthorized" do
    #     merchant = merchants(:quantum)
    #     get edit_merchant_url(merchant)
    #     assert_redirected_to merchants_login_url
    # end

    test "redirect 'new' if unauthorized" do
        get new_merchant_url
        assert_redirected_to root_path
    end

       
    test "redirect 'stripe_dashboard' if unauthorized" do
        merchant = merchants(:quantum)
        get stripe_dashboard_link_merchant_url(merchant)
        assert_response :unauthorized
    end
    
    test "do not redirect 'new_user' if unauthorized" do
        get merchants_new_user_url
        assert_response :ok
    end
    
    test "do not redirect 'enroll' if unauthorized" do
        get merchants_enroll_url, params: {state: 0, code: "TEST_OK"}
        assert_response :ok
    end
end