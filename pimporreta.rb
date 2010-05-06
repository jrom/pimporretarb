
require 'config'
require 'lib/helpers'

helpers do
  include Helpers # lib/helpers.rb
end

configure do
  enable :sessions
end

get '/' do
  @post = Post.find(:first, :conditions => ["published_on <= ?", Date.today], :order => "published_on DESC")
  if @post
    redirect @post.url
  else
    "NOTHING TO SEE HERE MOTHERFUCKER"
  end
end

get %r{\/(\d+)\-[a-z0-9\-\_\+]*}i do |id|
  begin
    @post = Post.find(id, :conditions => ["published_on <= ?", Date.today])
  rescue ActiveRecord::RecordNotFound
    redirect '/'
  end
  erb :index
end

post '/comment' do
  @post = Post.find(params[:post])
  redirect '/' unless @post
  @comment = @post.comments.build
  @comment.content = params[:content]
  spam_ok = true
  if logged_in?
    @comment.user_id = session[:user_id]
  else
    @comment.author = params[:name]
    unless params[:url] == "6"
      spam_ok = false
    end
  end
  @comment.save if spam_ok
  redirect @post.url
end

get '/new' do
  @last_post = Post.find(:first, :order => "published_on desc")
  protected!
  @post = Post.new
  erb :new
end

get '/login' do
  protected!
  redirect '/'
end

post '/new' do
  protected!
  @post = Post.new
  @post.title = params[:title]
  @post.content = params[:content]
  @post.kind = params[:kind]
  @post.user_id = session[:user_id]
  if @post.save
    redirect @post.url
  else
    @last_post = Post.find(:first, :order => "published_on desc")
    erb :new
  end
end

get '/saved/:id' do
  protected!
  @post = Post.find(params[:id], :conditions => ["user_id = ?", session[:user_id]])
  erb :saved
end

get '/list' do
  @posts = Post.find(:all, :conditions => ["published_on <= ?", Date.today], :order => "published_on desc")
  @title = "Arxiu d'entrades"
  erb :list
end

get '/comments' do
  @comments = Comment.find(:all, :include => :post, :conditions => ["posts.published_on <= ?", Date.today], :order => "comments.created_at DESC", :limit => 50)
  erb :comments
end

get '/saved' do
  @posts = Post.find(:all, :conditions => ["user_id = ? AND published_on > ?", session[:user_id], Date.today])
  @title = "Les teves entrades pendents de publicar"
  erb :list
end

get '/feed' do
  content_type :xml, :charset => "utf-8"
  @posts = Post.find(:all, :conditions => ["published_on <= ?", Date.today], :order => "published_on desc")
  builder :feed
end

get '/logout' do
  session[:login] = session[:user_id] = nil
  redirect '/'
end

get '/delete/:id' do
  protected!
  @post = Post.find(params[:id], :conditions => ["user_id = ?", session[:user_id]])
  if @post
    @post.destroy
    redirect '/'
  else
    redirect '/'
  end
end
