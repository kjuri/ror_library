class AddYearToBooks < ActiveRecord::Migration
  def change
    add_column :books, :year, :integer
  end
end
