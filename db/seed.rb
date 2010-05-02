puts "=========================="
u = User.create(:login => "jordi", :name => "Jordi", :password => Digest::SHA1.hexdigest("jordi"))
Post.create(:title => "Hola pimporreta!", :content => "Pimporreta 2010", :kind => 'q', :user_id => u.id)
puts "=========================="
