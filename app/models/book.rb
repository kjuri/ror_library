class Book < ActiveRecord::Base
  has_and_belongs_to_many :categories, join_table: "books_categories"
  belongs_to :author
  validates_presence_of :title, :author, :isbn
  validates_uniqueness_of :isbn

  self.per_page = 6
end
