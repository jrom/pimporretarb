class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :id
      t.string :login
      t.string :name
      t.string :password
    end
    add_index :users, :login, :unique => true
  end
  def self.down
    drop_table :users
    remove_index :login, :name
  end
end
