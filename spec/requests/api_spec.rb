# spec/requests/auth_spec.rb
# spec/requests/auth_spec.rb
require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  let(:user) { create(:user, email: 'test@example.com', password: '123456') }
  let(:other_user) { create(:user, email: 'intruder@example.com', password: '123456') }
  let(:headers) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: user.id)}" } }
  let(:other_headers) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: other_user.id)}" } }

  it "signs up successfully" do
    file = fixture_file_upload(Rails.root.join("spec", "fixtures", "files", "sample.jpg"), 'image/jpeg')
    post "/signup", params: {
      user: {
        name: "New User",
        email: "new@example.com",
        password: "123456",
        password_confirmation: "123456",
        image: file
      }
    }

    expect(response).to have_http_status(:created)
    expect(JSON.parse(response.body)).to have_key("user")
  end

  it "fails to sign up with missing parameters" do
    post "/signup", params: {
      user: {
        email: "incomplete@example.com",
        password: "123456"
      }
    }

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "fails signup with mismatched password confirmation" do
    post "/signup", params: {
      user: {
        name: "Bad Confirm",
        email: "bad@example.com",
        password: "123456",
        password_confirmation: "654321"
      }
    }

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "fails signup with invalid email format" do
    post "/signup", params: {
      user: {
        name: "Invalid Email",
        email: "invalidemail",
        password: "123456",
        password_confirmation: "123456"
      }
    }

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "logs in successfully (happy path)" do
    post "/login", params: {
      email: user.email,
      password: "123456"
    }.to_json, headers: { "Content-Type" => "application/json" }

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to have_key("token")
  end

  it "fails login with wrong credentials (unhappy path)" do
    post "/login", params: {
      email: user.email,
      password: "wrongpass"
    }.to_json, headers: { "Content-Type" => "application/json" }

    expect(response).to have_http_status(:unauthorized)
  end

  it "updates own profile successfully except email" do
    put "/users/#{user.id}", params: {
      user: {
        name: "Updated Name",
        password: "newpass",
        password_confirmation: "newpass"
      }
    }, headers: headers

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["user"]["name"]).to eq("Updated Name")
  end

  it "fails to update email in profile" do
    put "/users/#{user.id}", params: {
      user: {
        email: "hacker@example.com"
      }
    }, headers: headers

    expect(response).to have_http_status(:unprocessable_entity)
    expect(JSON.parse(response.body)["error"]).to include("Email can't be updated")
  end

  it "fails to update another user's profile" do
    put "/users/#{user.id}", params: {
      user: { name: "Hacked" }
    }, headers: other_headers

    expect(response).to have_http_status(:unauthorized)
  end

  it "deletes own profile successfully" do
    delete "/users/#{user.id}", headers: headers
    expect(response).to have_http_status(:no_content)
  end

  it "fails to delete another user's profile" do
    delete "/users/#{user.id}", headers: other_headers
    expect(response).to have_http_status(:unauthorized)
  end
end


# spec/requests/posts_spec.rb
require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let(:user) { create(:user, email: 'test@example.com', password: '123456') }
  let(:other_user) { create(:user) }
  let(:headers) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: user.id)}" } }
  let(:other_headers) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: other_user.id)}" } }
  let!(:post_record) { create(:post, user: user) }

  it "lists all posts" do
    get "/posts", headers: headers
    expect(response).to have_http_status(:ok)
  end

  it "shows a post" do
    get "/posts/#{post_record.id}", headers: headers
    expect(response).to have_http_status(:ok)
  end

  it "returns not found for non-existent post" do
    get "/posts/999999", headers: headers
    expect(response).to have_http_status(:not_found)
  end

  it "creates a new post" do
    post "/posts", params: {
      post: { title: "New", tags: "tag1", body: "Body" }
    }, headers: headers

    expect(response).to have_http_status(:created)
  end

  it "fails to create a post without auth" do
    post "/posts", params: {
      post: { title: "No Auth", tags: "test", body: "Fail" }
    }

    expect(response).to have_http_status(:unauthorized)
  end

  it "fails to create a post with missing title" do
    post "/posts", params: {
      post: { tags: "no title", body: "content" }
    }, headers: headers

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "fails to create a post with missing tags" do
    post "/posts", params: {
      post: { title: "No Tags", tags: "", body: "content" }
    }, headers: headers

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "updates a post" do
    put "/posts/#{post_record.id}", params: {
      post: { title: "Updated", tags: "new tags", body: "Updated body" }
    }, headers: headers

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["title"]).to eq("Updated")
  end

  it "fails to update a post with empty body" do
    put "/posts/#{post_record.id}", params: {
      post: { body: "" }
    }, headers: headers

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "fails to update post not owned by user" do
    put "/posts/#{post_record.id}", params: {
      post: { title: "Hacked" }
    }, headers: other_headers

    expect(response).to have_http_status(:unauthorized)
  end

  it "deletes a post" do
    delete "/posts/#{post_record.id}", headers: headers
    expect(response).to have_http_status(:no_content)
  end

  it "fails to delete post not owned by user" do
    delete "/posts/#{post_record.id}", headers: other_headers
    expect(response).to have_http_status(:unauthorized)
  end
end

# spec/requests/comments_spec.rb
require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:user) { create(:user, email: 'test@example.com', password: '123456') }
  let(:other_user) { create(:user) }
  let(:headers) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: user.id)}" } }
  let(:other_headers) { { "Authorization" => "Bearer #{JsonWebToken.encode(user_id: other_user.id)}" } }
  let!(:post_record) { create(:post, user: user) }
  let!(:comment) { create(:comment, post: post_record, user: user) }

  it "lists comments on a post" do
    get "/posts/#{post_record.id}/comments", headers: headers
    expect(response).to have_http_status(:ok)
  end

  it "creates a comment on a post" do
    post "/posts/#{post_record.id}/comments", params: {
      comment: { body: "Nice post!" }
    }, headers: headers

    expect(response).to have_http_status(:created)
  end

  it "fails to create comment with blank body" do
    post "/posts/#{post_record.id}/comments", params: {
      comment: { body: "" }
    }, headers: headers

    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "returns not found when commenting on non-existent post" do
    post "/posts/999999/comments", params: {
      comment: { body: "Ghost comment" }
    }, headers: headers

    expect(response).to have_http_status(:not_found)
  end

  it "fails to create comment without auth" do
    post "/posts/#{post_record.id}/comments", params: {
      comment: { body: "No token!" }
    }

    expect(response).to have_http_status(:unauthorized)
  end

  it "updates a comment" do
    put "/posts/#{post_record.id}/comments/#{comment.id}", params: {
      comment: { body: "Edited comment" }
    }, headers: headers

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)["body"]).to eq("Edited comment")
  end

  it "fails to update a comment not owned by user" do
    put "/posts/#{post_record.id}/comments/#{comment.id}", params: {
      comment: { body: "Hacked" }
    }, headers: other_headers

    expect(response).to have_http_status(:unauthorized)
  end

  it "deletes a comment" do
    delete "/posts/#{post_record.id}/comments/#{comment.id}", headers: headers
    expect(response).to have_http_status(:no_content)
  end

  it "fails to delete a comment not owned by user" do
    delete "/posts/#{post_record.id}/comments/#{comment.id}", headers: other_headers
    expect(response).to have_http_status(:unauthorized)
  end
end
