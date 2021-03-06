module Api
  module V1
    class ProductsController < ApplicationController
      respond_to :json
        def_param_group :product do
        param :product, Hash do
          param :name, String, "Name of the product"
          param :description_at, String
        end
      end
      api :GET, '/products' ,"View all products"
      def index
        # comments = Product.last.comments
        # product = Product.last
        # comments = product.comments
        sql ="select * from products p,comments c where p.id = c.product_id"
        comments = Product.find_by_sql(sql)
        respond_with comments
      end
      
      def show
        respond_with Product.find(params[:id])
      end
      api :POST, "/products", "Create an product"
      param_group :product
      def create
        respond_with Product.create(params[:product])
      end
      
      def update
        respond_with Product.update(params[:id], params[:products])
      end
      
      def destroy
        respond_with Product.destroy(params[:id])
      end
    end
  end
end



# class ProductsController < ApplicationController
#   before_action :set_product, only: [:show, :edit, :update, :destroy]

#   # GET /products
#   # GET /products.json
#   def index
#     @products = Product.all
#     respond_to do |format|
#     format.html
#     format.json { render json: @products }
#     end
#   end

#   # GET /products/1
#   # GET /products/1.json
#   def show
#   end

#   # GET /products/new
#   def new
#     @product = Product.new
#   end

#   # GET /products/1/edit
#   def edit
#   end

#   # POST /products
#   # POST /products.json
#   def create
#     @product = Product.new(product_params)

#     respond_to do |format|
#       if @product.save
#         format.html { redirect_to @product, notice: 'Product was successfully created.' }
#         format.json { render :show, status: :created, location: @product }
#       else
#         format.html { render :new }
#         format.json { render json: @product.errors, status: :unprocessable_entity }
#       end
#     end
#   end

#   # PATCH/PUT /products/1
#   # PATCH/PUT /products/1.json
#   def update
#     respond_to do |format|
#       if @product.update(product_params)
#         format.html { redirect_to @product, notice: 'Product was successfully updated.' }
#         format.json { render :show, status: :ok, location: @product }
#       else
#         format.html { render :edit }
#         format.json { render json: @product.errors, status: :unprocessable_entity }
#       end
#     end
#   end

#   # DELETE /products/1
#   # DELETE /products/1.json
#   def destroy
#     @product.destroy
#     respond_to do |format|
#       format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
#       format.json { head :no_content }
#     end
#   end

#   private
#     # Use callbacks to share common setup or constraints between actions.
#     def set_product
#       @product = Product.find(params[:id])
#     end

#     # Never trust parameters from the scary internet, only allow the white list through.
#     def product_params
#       params.require(:product).permit(:name, :description, :price)
#     end
# end
