class Admin::NhaCungCapsController < Admin::AdminController
 
  before_action :set_nha_cung_cap, only: [:show, :edit, :update, :destroy]

  # GET /nha_cung_caps
  # GET /nha_cung_caps.json
  def index
    @nha_cung_caps = NhaCungCap.all
  end

  # GET /nha_cung_caps/1
  # GET /nha_cung_caps/1.json
  def show
  end

  # GET /nha_cung_caps/new
  def new
    @nha_cung_cap = NhaCungCap.new
  end

  # GET /nha_cung_caps/1/edit
  def edit
    
  end

  # POST /nha_cung_caps
  # POST /nha_cung_caps.json
  def create
    @nha_cung_cap = NhaCungCap.new(nha_cung_cap_params)

    respond_to do |format|
      if @nha_cung_cap.save
        format.html { redirect_to @nha_cung_cap, notice: 'Nha cung cap was successfully created.' }
        format.json { render :show, status: :created, location: @nha_cung_cap }
      else
        format.html { render :new }
        format.json { render json: @nha_cung_cap.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nha_cung_caps/1
  # PATCH/PUT /nha_cung_caps/1.json
  def update
    respond_to do |format|
      if @nha_cung_cap.update(nha_cung_cap_params)
        format.html { redirect_to @nha_cung_cap, notice: 'Nha cung cap was successfully updated.' }
        format.json { render :show, status: :ok, location: @nha_cung_cap }
      else
        format.html { render :edit }
        format.json { render json: @nha_cung_cap.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nha_cung_caps/1
  # DELETE /nha_cung_caps/1.json
  def destroy
    @nha_cung_cap.destroy
    respond_to do |format|
      format.html { redirect_to nha_cung_caps_url, notice: 'Nha cung cap was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nha_cung_cap
      @nha_cung_cap = NhaCungCap.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def nha_cung_cap_params
      params.require(:nha_cung_cap).permit(:ten, :dia_chi, :email, :so_dien_thoai)
    end
end
