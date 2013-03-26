class AddExtensionToUser < ActiveRecord::Migration
  def change
    add_column :users, :extension, :string
  end
end
