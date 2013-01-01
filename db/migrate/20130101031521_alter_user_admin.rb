class AlterUserAdmin < ActiveRecord::Migration
  def self.up
    change_column :users, :adin, :integer, :default => 0
  end

  def self.down
    change_column :users, :adin, :integer, :default => 0
  end
end
