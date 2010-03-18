require 'sinatra/base'

class PimporretaRb < Sinatra::Base
  set :sessions, true

  get '/' do
    erb :index
  end
end
