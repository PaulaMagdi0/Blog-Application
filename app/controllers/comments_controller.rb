class CommentsController < ApplicationController


  # GET /posts/:post_id/comments
  def index
    post = Post.find(params[:post_id])
    comments = post.comments
    render json: comments
  end

  # POST /posts/:post_id/comments
  def create
    post = Post.find(params[:post_id])

    comment = post.comments.build(comment_params)
    comment.user_id = current_user.id
    if comment.save
      render json: comment, status: :created
    else
      render json: { error: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT post/post_id/comments/:id
  def update
    comment = Comment.find(params[:id])

    if comment.user_id == current_user.id
      if comment.update(comment_params)
        render json: comment
      else
        render json: { error: comment.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Not authorized to update this comment' }, status: :unauthorized
    end
  end

  # DELETE post/post_id/comments/:id
  def destroy
    comment = Comment.find(params[:id])

    if comment.user_id == current_user.id
      comment.destroy
      head :no_content
    else
      render json: { error: 'Not authorized to delete this comment' }, status: :unauthorized
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
