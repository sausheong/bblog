require './helpers'
require './workers'
require './models'

configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] ||= 'secret_sauce'
  set :protection, except: :session_hijacking  
  set :raise_errors, false
  
end

helpers Security, Web, Comms

## errors

error do 
  @name = env['sinatra.error'].name
  @message = env['sinatra.error'].message
  haml :"error.generic"
end

not_found do
  haml :"error.not_found"
end

error 401 do
  haml :"error.unauthorized", layout: :"layout.public"
end

## Web site

get "/login" do  
  haml :login, layout: false
end

get "/logout" do
  session.clear
  redirect "/"
end

post "/auth" do
  email = params[:email].downcase
  if user = User[email: email]
    if user.valid_password? params[:password]
      session[:user] = user.generate_session.uuid
      redirect "/posts"
    else
      flash[:error] = "Nope. Try again"
      redirect "/login"
    end
  else
    flash[:error] = "Nope. Try again"
    redirect "/login"
  end
end

get "/" do
  redirect "/posts" if session[:user]
  haml :index
end

require './routes/post'