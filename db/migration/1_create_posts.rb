class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :id
      t.string :title
      t.text :content
      t.string :author
      t.timestamps
    end
  end
  def self.down
    drop_table :posts
  end
end