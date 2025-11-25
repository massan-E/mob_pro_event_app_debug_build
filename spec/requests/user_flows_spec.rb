require "rails_helper"

RSpec.describe "ユーザーフロー", type: :request do
  describe "投稿一覧から他ユーザーの投稿を見る" do
    it "ログイン済みユーザーが別ユーザーの投稿リンクを開くと詳細が表示される" do
      signed_in_user = create(:user)
      other_user = create(:user)
      other_post = create(:post, user: other_user, title: "Other users post")

      sign_in(signed_in_user)

      get posts_path
      expect(response.body).to include(other_post.title)

      get post_path(other_post)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(other_post.title)
    end
  end

  describe "未ログインでトップの「はじめよう」ボタンを押下" do
    it "新規登録ページへ遷移できる" do
      get root_path
      doc = Nokogiri::HTML.parse(response.body)
      start_link = doc.css("a").find { |link| link.text.include?("はじめよう") }

      expect(start_link).to be_present

      get start_link[:href]
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("新規会員登録")
    end
  end

  describe "ログイン後ヘッダーのログアウトリンク" do
    it "クリックでログアウトできる" do
      user = create(:user)
      sign_in(user)

      get root_path
      doc = Nokogiri::HTML.parse(response.body)
      logout_link = doc.css("a").find { |link| link.text == "ログアウト" }

      expect(logout_link).to be_present
      expect(logout_link[:'data-turbo-method']).to eq("delete")

      method = logout_link[:'data-turbo-method']&.to_sym || :get
      public_send(method, logout_link[:href])
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Hello Debuggers")
      get new_post_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "自分の投稿詳細から削除リンク押下" do
    it "投稿が削除される" do
      user = create(:user)
      post = create(:post, user: user)
      sign_in(user)

      expect do
        delete post_path(post)
      end.to change(Post, :count).by(-1)

      expect(response).to redirect_to(posts_path)
      follow_redirect!
      expect(response.body).to include("削除しました")
    end
  end
end
