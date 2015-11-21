json.array!(@nha_cung_caps) do |nha_cung_cap|
  json.extract! nha_cung_cap, :id, :ten, :dia_chi, :email, :so_dien_thoai
  json.url nha_cung_cap_url(nha_cung_cap, format: :json)
end
