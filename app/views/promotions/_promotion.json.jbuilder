json.extract! promotion, :id, :name, :copy, :product, :end_date, :quantity, :image_url, :status, :created_at, :updated_at
json.url promotion_url(promotion, format: :json)
