class PostsController < ApplicationController

  # GET /posts
  def index
    posts = Post.all
    render json: posts
  end

  # GET /posts/:id
  def show
    post = Post.find(params[:id])
    render json: post
  end

  # POST /posts
  def create
    post = current_user.posts.build(post_params)
    if post.save
      render json: post, status: :created
    else
      render json: { error: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/:id
  def update
    post = Post.find(params[:id])

    if post.user_id == current_user.id
      if post.update(post_params)
        render json: post
      else
        render json: { error: post.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Not authorized to update this post' }, status: :unauthorized
    end
  end

  # DELETE /posts/:id
  def destroy
    post = Post.find(params[:id])

    if post.user_id == current_user.id
      post.destroy
      head :no_content
    else
      render json: { error: 'Not authorized to delete this post' }, status: :unauthorized
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :tags)
  end
end
