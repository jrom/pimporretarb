
class Post < ActiveRecord::Base
  has_many :comments
  belongs_to :user
  def to_param
    title.nil? ? "#{id}-" : "#{id}-#{title.gsub(/[^a-z0-9\-_\+]+/i, '-').downcase}"
  end
  def url
    if self.published_on <= Date.today
      "/#{self.to_param}"
    else
      "/saved/#{self.id}"
    end
  end
  
  def next
    self.class.find(:first, :conditions =>  ['id > ? AND published_on <= ?', self.id, Date.today])
  end
  def prev
    self.class.find(:last, :conditions =>  ['id < ? AND published_on <= ?', self.id, Date.today])
  end
  
  validates_presence_of :content
  validates_presence_of :title
  validates_presence_of :user  
  validates_presence_of :kind
  before_create :set_published
  
  def show_content
    case self.kind
    when 'l' then
      link, msg = self.content.split("\n", 2)
      "<p><a href='#{link}' title='#{self.title} a pimporreta.org'/>#{self.title}</a>#{Markdown.new(msg).to_html}"
    when 'p' then
      link, msg = self.content.split("\n", 2)
      "<p><img src='#{link}' alt='#{self.title} a pimporreta.org'/></p>#{Markdown.new(msg).to_html}"
    when 'v','t' then
      self.content
    when 'q' then
      "&laquo;#{self.content}&raquo;"
    else
      self.content
    end
  end
  
  def title_list
    case self.kind
    when 'q' then
      "#{self.content} &mdash; #{self.title}"
    else
      self.title
    end
  end
  
  private
  def set_published
    p = Post.find(:first, :order => 'published_on desc', :conditions => ["published_on >= ?", Date.today])
    self.published_on = p.nil? ? Date.today : (p.published_on.to_date + 1)
  end

end
class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user

  validates_presence_of :content
  validates_presence_of :post
  
  def author_name
    if self.user
      self.user.name
    else
      self.author
    end
  end
end

class User < ActiveRecord::Base
  has_many :posts
  has_many :comments

  validates_uniqueness_of :login
  validates_presence_of :login
  validates_presence_of :name
  validates_presence_of :password
end
