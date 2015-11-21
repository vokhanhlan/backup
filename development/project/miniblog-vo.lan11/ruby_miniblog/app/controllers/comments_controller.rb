class CommentsController < ApplicationController

layout false

before_action :set_comment, only: [:show, :edit, :update, :destroy]

def new
	@comment = Comment.new

end

def show
	
	
end

def edit
	render :partial =>false

end

def update
	render :partial =>false
	if @comment.update(comment_params)
       redirect_to @post, :comment=>"Update comment successfully"
    else
       redirect_to @post
    end
	
end
# Add new comment
def create
	@post = Post.find(params[:comment][:post_id])
	@comment = Comment.new(comment_params)
	if @comment.save
		redirect_to @post, :comment=>"Post comment successfully"
	else
		redirect_to @post
    end
end
    
def destroy
	
    if @comment.destroy
      redirect_to @post, :comment=>"Delete comment successfully"
    else
      redirect_to @post, :comment=>"Delete comment unsuccessfully"
    end
end

private
# find comment

def set_comment
	@comment = Comment.find(params[:id])
	@post = Post.find(@comment.post_id)
	
end

# set params for comment
def comment_params
	params.require(:comment).permit(:content,:post_id,:user_id)
	 	
end
end
