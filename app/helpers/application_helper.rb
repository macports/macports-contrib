# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def obfuscate_email(email)
    email.sub!(/@/, '<img src="/images/at.gif" alt="at" />') 
    return "<span class=\"email\">#{email}</span>"
  end
end
