require 'json'

class OrderEmails < EmailBase
  def download_order(email, name, order_id)

    @name = name
    @order_id = order_id
    @download_link_prefix = JSON.parse(File.read(File.dirname(__FILE__) + '/../config/emails.json'), symbolize_names: true)[:download_link]

    prepare_email to: email, subject: 'ORDER CONFIRMATION'
  end

  def order_placed(email, name, order_id)

    @name = name
    @order_id = order_id

    prepare_email to: email, subject: 'YOUR ORDER IS ALMOST READY'
  end
end