class ReservationMailer < ActionMailer::Base
  default from: 'notifications@example.com'

  def create_reservation_notifier(user, date, date_of_return)
    @date = date
    @return = date_of_return
    mail :to => user.email, :subject => "Powiadomienie o rezerwacji"
  end
end
