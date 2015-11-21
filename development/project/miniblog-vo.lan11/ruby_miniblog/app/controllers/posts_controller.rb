class PostsController < ApplicationController
  
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  
  skip_before_action :verify_authenticity_token

  def index
    @title = "Posts"
    add_breadcrumb "Posts", :posts_path
    @post_read_mores = Post.where("count_view > 0").order("count_view desc").limit(4)
    if params[:user_post]
       @posts = Post.post_of_user(params[:user_post]).paginate(:page => params[:page], :per_page => 4)
       flash[:count] = @posts.count
       flash[:name] = User.select(:id,:username).find_by_id(params[:user_post])
       
    else
       @posts = Post.all.paginate(:page => params[:page], :per_page => 4)

    end
  end

  def show
    @title =  @post.title
    add_breadcrumb "Post", :post_path
    @comments = @post.comment
    @post.update_count_view(@post.id, @post.count_view)
    @post_of_users = Post.post_of_user(@post.user_id)

  end

  def new
     @title =  "Create post"
     add_breadcrumb "Create post", :new_post_path
     @post = Post.new
  
  end

  def edit
   @title =  "Edit | " << @post.title
   add_breadcrumb "Edit post", :edit_post_path

  end

  def update_comment
    
    @post = Post.find(params[:comment][:post_id])
    comment = Comment.find(params[:comment][:id])
    if comment.update(:content =>params[:comment][:content])
      redirect_to @post
    end
  end

  def create
    #byebug
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to posts_path, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def set_post
      @post = Post.find(params[:id])

  end

    # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
      params.require(:post).permit(:title, :content, :description, :user_id, :status,:image)
      
  end
end
