module Api
  module V2
    class ProductsController < ApplicationController      
      respond_to :json
      
      def index
        products = Product.all
        respond_with products
      end
      
      def show
        product = Product.find(params[:id]) 

        respond_with product.merge_json(:total => product.total_price)
      
        product.user.profile.last_name
        
        user = product.user
        last_name = user.profile.last_name
      end
      
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
