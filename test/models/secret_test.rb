require 'test_helper'

class SecretTest < ActiveSupport::TestCase

    test "Create and Retreive a secret" do
        rand = Random.rand()
        secret = Secret.create(rand)
        assert Secret.exists?(secret)
        assert_equal rand, Secret.find(secret)
        refute Secret.exists?(secret)
    end

end