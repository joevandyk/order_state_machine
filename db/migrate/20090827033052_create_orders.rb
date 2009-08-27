class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.string  :state
      t.decimal :total
      t.string  :tracking_number
      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
