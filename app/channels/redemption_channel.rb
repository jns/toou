class RedemptionChannel < ApplicationCable::Channel
  def subscribed
    stream_from params[:pass_sn]
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
