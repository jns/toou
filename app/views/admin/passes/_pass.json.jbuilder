json.extract! pass, :serial_number, :expiration, :passTypeIdentifier, :message, :created_at, :updated_at, :account
json.url pass_url(pass, format: :json)
