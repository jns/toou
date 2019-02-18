class PublicKeysController < ApplicationController
	
	layout false
	skip_before_action :validate_auth_token
    
	# GET returns the stripe public api key
	def stripe_key
		render json: {"stripe_public_api_key": ENV["STRIPE_PUBLIC_KEY"]}, status: :ok
	end
	
	def stripe_client_id
		render json: {"stripe_client_id": ENV["STRIPE_CLIENT_ID"]}, status: :ok	
	end
	
end
