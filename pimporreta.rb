require 'sinatra'
require 'active_record'
require 'bluecloth'

require 'config'
require 'lib/models'

helpers do

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

post '/comment' do
  p = Post.find(params[:post])
  c = p.comments.build
  c.author = params[:name]
  c.content = params[:content]
  c.save
  redirect "#{p.url}\#comments"
end