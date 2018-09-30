json.extract! pass, :id, :serialNumber, :expiration, :passTypeIdentifier, :message, :created_at, :updated_at, :account
json.url pass_url(pass, format: :json)
