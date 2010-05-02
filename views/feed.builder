xml.instruct!
xml.feed :xmlns => "http://www.w3.org/2005/Atom" do
  xml.title "pimporreta.org", :type => "text"
  xml.updated @posts.empty? ? Time.parse(Time.now).xmlschema : @posts[0].published_on.xmlschema
  xml.generator "pimporreta.org", :uri => "http://pimporreta.org"
  xml.id "tag:#{request.host},2010:/"
  xml.link :href => "#{base_url}/feed", :rel => "self"
  xml.link :href => base_url, :rel => "alternate"
  @posts.each do |post|
    xml.entry do
      xml.title post.title_list, :type => "html"
      xml.link :href => post.url,
               :type => "text/html",
               :rel => "alternate"
      xml.id "tag:#{request.host},#{post.published_on.strftime('%Y-%m-%d')}:#{post.url}"
      xml.content absolute_urls(post.show_content), :type => "html"
      xml.published post.published_on.xmlschema
      xml.updated post.published_on.xmlschema
      xml.author do |author|
        xml.name post.user.name
      end
    end
  end
end
