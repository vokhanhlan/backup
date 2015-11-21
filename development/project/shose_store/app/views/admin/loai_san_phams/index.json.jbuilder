json.array!(@loai_san_phams) do |loai_san_pham|
  json.extract! loai_san_pham, :id, :ten, :,, :ma_loai_cha
  json.url loai_san_pham_url(loai_san_pham, format: :json)
end
