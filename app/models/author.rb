class Author < ActiveRecord::Base
  has_many :books
  validates_presence_of :first_name, :last_name
  validates_uniqueness_of :last_name, :scope => :first_name
  self.per_page = 10

  def full_name
    "#{self.first_name} #{self.last_name}"
  end
end
