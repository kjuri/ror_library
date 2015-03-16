class AddIsbnToBooks < ActiveRecord::Migration
  def change
    add_column :books, :isbn, :text
  end
end
