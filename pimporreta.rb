require 'sinatra'
require 'active_record'

require 'config'
require 'lib/models'


get '/' do
  @post = Post.last
  if @post
    redirect @post.url
  end
end

get %r{\/(\d+)\-[a-z0-9\-\_\+]+}i do |id|
  @post = Post.find(id)
  erb :index
end
