json.extract! pass, :id, :serialNumber, :expiration, :passTypeIdentifier, :created_at, :updated_at
json.url pass_url(pass, format: :json)
