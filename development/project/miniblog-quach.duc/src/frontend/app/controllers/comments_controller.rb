class CommentsController < ApplicationController
  # Set funtions use partial funtion in private
   before_action :set_comment, only: [:show, :edit, :update, :destroy]
  def create
    @comment = Comment.new(comment_params)
     respond_to do |format|
      flash[:alert] = "Something went wrong !"
      @comment.save ? format.js { render :action => "create_ok"} : format.js { render :action => "create_fail"}
    end
  end

   def new
    # DESC===========================
    # Init new comment for partial form
    # IN:
    # OUT: record empty for partial form
    # DESC===========================
    @comment = Comment.new
  end

    def destroy
    # DESC===========================
    # Destroy comment
    # IN: comment attr
    # OUT: delete this comment in database
    # DESC===========================

     @comment.destroy
     redirect_to :back, :flash => { :notice => "Delete comment successfully" }
  end

    def update
      respond_to do |format|
        if @comment.update(comment_params)
           format.js { render :action => "create_ok"}
        else
           format.js { render :action => "create_fail"}
        end
      end
    end

  private
    def set_comment
      # DESC===========================
      # Partial for funtions use (edit, delete)
      # IN: params[:id]
      # OUT: comment have this id
      # DESC===========================
      @comment = Comment.find(params[:id])
    end
    def comment_params
      # DESC===========================
      # Filter params to get comment's param
      # IN: params
      # OUT: comment_params
      # DESC===========================
      params.require(:comment).permit(:content, :user_id, :post_id)
    end
end