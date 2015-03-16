class CreateReservations < ActiveRecord::Migration
  def self.up
    create_table :reservations do |t|
      t.datetime :reserved_on
      t.references :book, index: true
      t.references :user, index: true

      t.timestamps
    end
  end

  def self.down
    drop_table :reservations
  end
end
