class Admin::SanPhamsController < Admin::AdminController
  before_action :set_san_pham, only: [:show, :edit, :update, :destroy]

  # GET /san_phams
  # GET /san_phams.json
  def index
    @san_phams = SanPham.all.paginate(page: params[:page], per_page: 2)
  end

  # GET /san_phams/1
  # GET /san_phams/1.json
  def show
  end

  # GET /san_phams/new
  def new
    @san_pham = SanPham.new
    @loai_sps = LoaiSanPham.all
    @nhaccs = NhaCungCap.all
  end

  # GET /san_phams/1/edit
  def edit
    
  end

  # POST /san_phams
  # POST /san_phams.json
  def create
    @san_pham = SanPham.new(san_pham_params)

    respond_to do |format|
      if @san_pham.save
        format.html { redirect_to admin_san_phams_url, notice: 'San pham was successfully created.' }
        format.json { render :show, status: :created, location: @san_pham }
      else
        format.html { render :new }
        format.json { render json: @san_pham.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /san_phams/1
  # PATCH/PUT /san_phams/1.json
  def update
    respond_to do |format|
      if @san_pham.update(san_pham_params)
        format.html { redirect_to admin_san_phams_url, notice: 'San pham was successfully updated.' }
        format.json { render :show, status: :ok, location: @san_pham }
      else
        format.html { render :edit }
        format.json { render json: @san_pham.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /san_phams/1
  # DELETE /san_phams/1.json
  def destroy
    @san_pham.destroy
    respond_to do |format|
      format.html { redirect_to admin_san_phams_url, notice: 'San pham was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

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
