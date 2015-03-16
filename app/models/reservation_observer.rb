class ReservationObserver < ActiveRecord::Observer
  def after_create(reservation)
    ReservationMailer.deliver_test_message(user)
  end
end
