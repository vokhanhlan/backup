class CommentsController < ApplicationController
def new
end
def create
	@new_comment = Comment.new(comment_params)
	 respond_to do |format|
  if @new_comment.save
    format.html { redirect_to san_pham_url(@new_comment.commentable), notice: 'Comment was succemmessfully created.' }
    format.js
   #(@new_comment.commentable)
  else
    format.html { render :new }
    format.js
  end
 end
end

def show

end

def comment_params
	params.require(:comment).permit(:comment,:commentable_id,:commentable_type,:nguoi_dung_id)
end
end

