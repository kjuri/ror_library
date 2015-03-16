class Category < ActiveRecord::Base
  has_and_belongs_to_many :books, join_table: "books_categories"
  validates_presence_of :name
  validates_uniqueness_of :name

  self.per_page = 10;
end
