class Order < ActiveRecord::Base
  class BillingError < RuntimeError; end

  after_create :process
  after_create :log_creation

  attr_accessor :bad_card

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

    before_transition :to => :authorized, :do => :execute_authorization

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

  def execute_authorization
    if @bad_card.present?
      errors.add(:bad_card, "is bad")
      # Not thrilled about this, but we have to stop the record from being saved.
      # And state_machine seems to only work properly on saved records.
      raise BillingError.new
    end
  end
end
