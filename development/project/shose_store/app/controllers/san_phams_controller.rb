class SanPhamsController < ApplicationController
  before_action :set_san_pham, only: [:show]

  # GET /san_phams
  # GET /san_phams.json
  def index
    @san_phams = SanPham.all.paginate(page: params[:page], per_page: 3)
  end

  # GET /san_phams/1
  # GET /san_phams/1.json
  def show
    @new_comment = Comment.new
    @comments = @san_pham.comments.order("updated_at DESC")
  end

  # GET /san_phams/new

  # DELETE /san_phams/1
  # DELETE /san_phams/1.json

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_san_pham
      @san_pham = SanPham.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def san_pham_params
      params.require(:san_pham).permit(:ma_loai_san_pham, :ma_nha_cung_cap, :ten, :don_gia, :mo_ta, :san_pham_moi, :trang_thai, :ngay_san_xuat, :hinh)
    end
end
