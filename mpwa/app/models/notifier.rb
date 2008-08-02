class Notifier < ActionMailer::Base
  
  def user_validation(user, token)
    # Email header info MUST be added here
    recipients user.email
    from  "do_not_reply@macports.com"
    subject "MacPorts user validation" 

    # Email body substitutions go here
    body :user => user, :token -> token
  end
  
end
