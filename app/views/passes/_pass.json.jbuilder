json.extract! pass, :id, :serialNumber, :expiration, :passTypeIdentifier, :created_at, :updated_at, :account
json.url pass_url(pass, format: :json)
