require 'sinatra'
require 'active_record'
require 'bluecloth'

require 'config'
require 'lib/models'

helpers do

  def protected!
    unauthorized and return unless authorized?
    session[:login] = true
  end
  
  def unauthorized
    response['WWW-Authenticate'] = %(Basic realm="pimporreta") and \
      throw(:halt, [401, "Not authorized\n"])
  end
  
  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && authenticate(@auth.credentials[0], @auth.credentials[1])
  end

  def authenticate(user, pass)
    u = User.find_by_login(user)
    puts "LOGIN: " + u.inspect
    if u && u.password == pass
      session[:user_id] = u.id
      return true
    else
      return false
    end
  end
  
  def logged_in?
    session[:login] == true
  end

  def md(s)
    options = {
    }
    BlueCloth.new(s, options).to_html
  end
  def time_ago_words(from_time, to_time = 0, include_seconds = false, options = {})
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round

    case distance_in_minutes
      when 0..1
        return distance_in_minutes == 0 ?
               "menys d'un minut" :
               "#{distance_in_minutes} minuts" unless include_seconds

        case distance_in_seconds
          when 0..4   then "menys de 5 segons"
          when 5..9   then "menys de 10 segons"
          when 10..19 then "menys de 20 segons"
          when 20..39 then "mig minut"
          when 40..59 then "menys d'un minut"
          else             "un minut"
        end
      when 2..44           then "#{distance_in_minutes} minuts"
      when 45..89          then "aproximadament una hora"
      when 90..1439        then "aproximadament #{(distance_in_minutes.to_f / 60.0).round} hores"
      when 1440..2879      then "un dia"
      when 2880..43199     then "#{(distance_in_minutes / 1440).round} dies"
      when 43200..86399    then "aproximadament un mes"
      when 86400..525599   then "#{(distance_in_minutes / 43200).round} mesos"
      when 525600..1051199 then "aproximadament un any"
      else                      "#{(distance_in_minutes / 525600).round} anys"
    end
  end
end

configure do
  enable :sessions
end

get '/' do
  @post = Post.find(:last, :conditions => ["published_on <= ?", Date.today])
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
  p = Post.find(params[:post])
  c = p.comments.build
  c.content = params[:content]
  if logged_in?
    c.user_id = session[:user_id]
  else
    c.author = params[:name]
  end
  c.save
  if p.published_on > Date.today
    redirect "/saved/#{p.id}"
  else
    redirect p.url
  end
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
    redirect "/saved/#{@post.id}"
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
