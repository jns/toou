require 'test_helper'

class PassTest < ActiveSupport::TestCase

  test "Pass status is expired if past expiration date" do
      assert_equal Pass::EXPIRED, passes(:expired).status
  end
  
  test "Pass statis is valid if in the distant future" do
      assert_equal Pass::VALID, passes(:distant_future).status
  end

end
