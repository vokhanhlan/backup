class LoaiSanPhamsController < ApplicationController
  before_action :set_loai_san_pham, only: [:show]

  # GET /loai_san_phams
  # GET /loai_san_phams.json
  def index
    @san_phams = SanPham.all.paginate(page: params[:page], per_page: 3)
  end

  # GET /loai_san_phams/1
  # GET /loai_san_phams/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_loai_san_pham
      @loai_san_pham = LoaiSanPham.find(params[:id])
      @san_phams = SanPham.where(ma_loai_san_pham: params[:id]).paginate(page: params[:page], per_page: 3)
      #@san_phams = @loai_san_pham.san_phams.avaiable
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def loai_san_pham_params
      params.require(:loai_san_pham).permit(:ten,:ma_loai_cha)
    end
end
