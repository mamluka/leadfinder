require_relative 'mail_base'

class OrderEmails < EmailBase
  def download_order(email, file_id)

    @file_id = file_id
    prepare_email to: email, subject: 'Here is your order from LeadFinder'
  end
end