require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  def setup
    @free_order     = Order.create! :total => 0
    @paid_order     = Order.create! :total => 10
    @captured_order = Order.create!(:total => 10);  @captured_order.capture!
  end

  test "can cancel a free order" do
    @free_order.cancel!
    assert @free_order.cancelled?
  end

  test "can cancel paid order" do
    @paid_order.cancel!
  end

  test "can't cancel captured order" do
    assert ! @captured_order.can_cancel?
  end

  test "can't cancel orders once it's being processed" do
    [@free_order, @captured_order].each do |order|
      order.prepare_for_shipping!
      assert ! order.can_cancel?
    end
  end

  test "can ship stuff with tracking number" do
    tracking_number = "12345"
    @captured_order.prepare_for_shipping!
    @captured_order.import_shipping! tracking_number
    assert @captured_order.shipped?
    assert_equal tracking_number, @captured_order.tracking_number
  end

  test "can ship stuff without tracking number" do
    @captured_order.prepare_for_shipping!
    @captured_order.mark_as_shipped!
    assert @captured_order.shipped?
    assert @captured_order.tracking_number.blank?
  end

end
