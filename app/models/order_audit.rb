class OrderAudit < ActiveRecord::Base
  belongs_to :order

  def self.log order, text
    self.create! :order => order, :description => text.humanize
    # puts "#{order.id} #{ text}"
  end
end
