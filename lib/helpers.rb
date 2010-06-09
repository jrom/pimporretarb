
module Helpers

  include Rack::Utils
  alias_method :h, :escape_html

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
    if u && u.password == Digest::SHA1.hexdigest(pass)
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
  
  # From Rails source
  def auto_link_urls(text, html_options = {})
    auto_link_re = %r{ ( https?:// | www\. ) [^\s<]+ }x
    brackets = { ']' => '[', ')' => '(', '}' => '{' }

    text.gsub(auto_link_re) do
      href = $&
      punctuation = ''
      left, right = $`, $'
      # detect already linked URLs and URLs in the middle of a tag
      if left =~ /<[^>]+$/ && right =~ /^[^>]*>/
        # do not change string; URL is alreay linked
        href
      else
        # don't include trailing punctuation character as part of the URL
        if href.sub!(/[^\w\/-]$/, '') and punctuation = $& and opening = brackets[punctuation]
          if href.scan(opening).size > href.scan(punctuation).size
            href << punctuation
            punctuation = ''
          end
        end

        link_text = block_given?? yield(href) : href
        href = 'http://' + href unless href.index('http') == 0
        "<a href=\"#{href}\" >#{h(link_text)}</a>#{punctuation}"
      end
    end
  end
  def base_url
    url = "http://#{request.host}"
    request.port == 80 ? url : url + ":#{request.port}"
  end

  def absolute_urls(text)
    text.gsub!(/(<a href=['"])\//, '\1' + base_url + '/')
    text.gsub!(/(<img src=['"])\//, '\1' + base_url + '/')
    text
  end

  # Github Flavoured Markdown from http://github.github.com/github-flavored-markdown/
  def gfm(text)
    # Extract pre blocks
    extractions = {}
    text.gsub!(%r{<pre>.*?</pre>}m) do |match|
      md5 = Digest::MD5.hexdigest(match)
      extractions[md5] = match
      "{gfm-extraction-#{md5}}"
    end

    # prevent foo_bar_baz from ending up with an italic word in the middle
    text.gsub!(/(^(?! {4}|\t)\w+_\w+_\w[\w_]*)/) do |x|
      x.gsub('_', '\_') if x.split('').sort.to_s[0..1] == '__'
    end

    # in very clear cases, let newlines become <br /> tags
    text.gsub!(/^[\w\<][^\n]*\n+/) do |x|
      x =~ /\n{2}/ ? x : (x.strip!; x << "  \n")
    end

    # Insert pre block extractions
    text.gsub!(/\{gfm-extraction-([0-9a-f]{32})\}/) do
      "\n\n" + extractions[$1]
    end

    Markdown.new(Sanitize.clean(text)).to_html
  end

end
