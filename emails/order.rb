class OrderEmails < EmailBase
  def download_order(email, name, order_id)

    @name = name
    @order_id = order_id

    prepare_email to: email, subject: 'ORDER CONFIRMATION'
  end
end