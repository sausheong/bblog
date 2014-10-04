# Shows all posts
get "/posts" do
  require_login
  @current_page = (params[:page] || 1).to_i
  page_size = params[:page_size] || 10
  @posts = @user.posts_dataset.reverse_order(:created_at).paginate(@current_page, page_size.to_i)
  haml :posts  
end

# Show a single post
get "/posts/post/:uuid" do
  require_login
  @post = Post[uuid: params[:uuid]]
  haml :post
end

# Show the create post form
get "/post/new" do
  require_login
  haml :"post.new"
end

# Show the edit post form
get "/posts/post/:uuid/edit" do
  require_login
  @post = Post[uuid: params[:uuid]]
  haml :"post.edit"
end

# Create or modify a post
post "/post" do
  require_login
  # if uuid exists, this is an existing post
  if params[:uuid]
    # get the post
    post = Post[uuid: params[:uuid]]
    # update it
    post.update title: params[:title], content: params[:content]
  else
    # create a new post
    Post.create user: @user, title: params[:title], content: params[:content]
  end
  redirect "/"  
end

