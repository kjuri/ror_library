class UserMailer < ActionMailer::Base
  def test_message(user)
    mail(:to => user.email, :subject => 'Witaj w najlepszej bibliotece świata!', :from => 'marcinsz92@gmail.com')
  end
end
