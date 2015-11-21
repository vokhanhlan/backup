class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  layout "application_v2"
  before_action :set_loai_san_phams,:authenticate_nguoi_dung!
   def set_loai_san_phams
  	@loai_san_phams = LoaiSanPham.all
  end
end
