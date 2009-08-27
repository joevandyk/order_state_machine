class Order < ActiveRecord::Base
  after_create :log_creation
  after_create :process!

  has_many :audits, :class_name => 'OrderAudit', :order => 'id asc'

  def free?
    self.total == 0
  end

  state_machine :initial => :placed do
    event :process do 
      transition :placed => :authorized,          :unless => :free?
      transition :placed => :ready_for_shipping,  :if     => :free?
    end                                      

    event :capture do
      transition :authorized => :captured
    end

    event :ready_for_shipping do
      transition :captured => :ready_for_shipping
    end

    event :cancel do
      transition :authorized          => :cancelled, :unless => :free?
      transition :ready_for_shipping  => :cancelled, :if     => :free?
    end

    event :refund do
      transition [:captured, :ready_for_shipping] => :refunded
    end

    event :prepare_for_shipping do
      transition :ready_for_shipping => :preparing_for_shipping
    end

    event :import_shipping do |tracking|
      transition :preparing_for_shipping => :shipped
    end

    event :mark_as_shipped do
      transition :preparing_for_shipping => :shipped
    end

    after_transition do |o, transition|
      o.log "is #{transition.to.humanize}"
    end

    after_transition any => :captured do |order, transition|
      order.ready_for_shipping!
    end
  end

  def log text
    OrderAudit.log(self, text)
  end

  def import_shipping number
    self.tracking_number = number
    super # finishes state transition
  end

  def log_creation
    log "has been placed"
  end
end
