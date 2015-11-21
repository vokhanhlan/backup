class Admin::LoaiSanPhamsController < Admin::AdminController
  before_action :set_loai_san_pham, only: [:show, :edit, :update, :destroy]

  # GET /loai_san_phams
  # GET /loai_san_phams.json
  def index
    @san_phams = SanPham.all.paginate(page: params[:page], per_page: 3)
  end

  # GET /loai_san_phams/1
  # GET /loai_san_phams/1.json
  def show
  end

  # GET /loai_san_phams/new
  def new
    @loai_san_pham = LoaiSanPham.new
  end

  # GET /loai_san_phams/1/edit
  def edit
  end

  # POST /loai_san_phams
  # POST /loai_san_phams.json
  def create
    @loai_san_pham = LoaiSanPham.new(loai_san_pham_params)

    respond_to do |format|
      if @loai_san_pham.save
        format.html { redirect_to @loai_san_pham, notice: 'Loai san pham was successfully created.' }
        format.json { render :show, status: :created, location: @loai_san_pham }
      else
        format.html { render :new }
        format.json { render json: @loai_san_pham.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /loai_san_phams/1
  # PATCH/PUT /loai_san_phams/1.json
  def update
    respond_to do |format|
      if @loai_san_pham.update(loai_san_pham_params)
        format.html { redirect_to @loai_san_pham, notice: 'Loai san pham was successfully updated.' }
        format.json { render :show, status: :ok, location: @loai_san_pham }
      else
        format.html { render :edit }
        format.json { render json: @loai_san_pham.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /loai_san_phams/1
  # DELETE /loai_san_phams/1.json
  def destroy
    @loai_san_pham.destroy
    respond_to do |format|
      format.html { redirect_to loai_san_phams_url, notice: 'Loai san pham was successfully destroyed.' }
      format.json { head :no_content }
    end
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
