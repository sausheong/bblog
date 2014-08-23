get "/posts" do
  require_login
  @current_page = (params[:page] || 1).to_i
  page_size = params[:page_size] || 10
  @posts = @user.posts_dataset.reverse_order(:created_at).paginate(@current_page, page_size.to_i)
  haml :posts  
end

get "/post/new" do
  require_login
  haml :"post.new"
end

get "/posts/post/:id" do
  require_login
  haml :post
end

post "/post" do
  require_login
  Post.create user: @user, title: params[:title], content: params[:content]
  redirect "/"  
end