class RemovePassFromQueue < ApplicationJob
    queue_as :default

    def perform(queue_object)
        begin
            MerchantPassQueue.find(queue_object).destroy
        rescue ActiveRecord::RecordNotFound
            # No-op
        end    
    end
end
