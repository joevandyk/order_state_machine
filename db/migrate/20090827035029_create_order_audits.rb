class CreateOrderAudits < ActiveRecord::Migration
  def self.up
    create_table :order_audits do |t|
      t.integer :order_id
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :order_audits
  end
end
