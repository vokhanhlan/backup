json.array!(@comments) do |comment|
  json.extract! comment, :id, :content, :product_id
  json.url comment_url(comment, format: :json)
end
