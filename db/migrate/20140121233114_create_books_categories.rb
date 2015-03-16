class CreateBooksCategories < ActiveRecord::Migration
  def self.up
    create_table :books_categories, :id => false do |t|
      t.references :book
      t.references :category
    end
    add_index :books_categories, [:book_id, :category_id], :unique => true
  end

  def self.down
    drop_table :books_categories
  end
end
