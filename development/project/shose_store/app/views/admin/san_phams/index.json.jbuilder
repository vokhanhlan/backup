json.array!(@san_phams) do |san_pham|
  json.extract! san_pham, :id, :ma_loai_san_pham, :ma_nha_cung_cap, :ten, :don_gia, :mo_ta, :san_pham_moi, :trang_thai, :ngay_san_xuat, :datetime
  json.url san_pham_url(san_pham, format: :json)
end
