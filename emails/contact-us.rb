class ContactUsEmails < EmailBase
  def contact_form(email, your_email, message)
    @your_email = your_email
    @message = message

    prepare_email to: email, subject: "#{your_email} wanted us to contact him"
  end
end