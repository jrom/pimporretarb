
class ActiveRecord::Base
  def next
    self.class.find(:first, :conditions =>  ['id > ?', self.id])
  end
  def prev
    self.class.find(:first, :conditions =>  ['id < ?', self.id])
  end
end

class Post < ActiveRecord::Base
  has_many :comments
  def to_param
    "#{id}-#{title.gsub(/[^a-z0-9\-_\+]+/i, '-').downcase}"
  end
  def url
    "/#{to_param}"
  end
end
class Comment < ActiveRecord::Base
  belongs_to :post
end
