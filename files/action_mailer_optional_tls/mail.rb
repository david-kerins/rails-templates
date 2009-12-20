ActionMailer::Base.smtp_settings = {
  :tls            => true,
  :address        => "smtp.gmail.com",
  :port           => "587",
  :domain         => "domain.com",
  :authentication => :plain,
  :user_name      => "user@domain.com",
  :password       => "password" 
}