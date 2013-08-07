require 'paypal-sdk-rest'
require 'json'

class Paypal

  def initialize
    @config = JSON.parse(File.read(File.dirname(__FILE__) + '/config.json'), symbolize_names: true)

    PayPal::SDK::REST.set_config(
        :mode => :sandbox,
        :client_id => @config[:pp_client_id],
        :client_secret => @config[:pp_client_secret]
    )

  end

  def get_charge_link(options)


    paypal = PayPal::SDK::REST::Payment.new({
                                                :intent => 'sale',
                                                :payer => {
                                                    :payment_method => 'paypal'
                                                },
                                                redirect_urls: {
                                                    return_url: @config[:pp_approve_url],
                                                    cancel_url: @config[:pp_cancel_url]
                                                },
                                                :transactions => [{
                                                                      :amount => {
                                                                          :total => sprintf('%.2f', options[:amount]),
                                                                          :currency => 'USD',
                                                                      },
                                                                      :description => "Your order of #{options[:number_of_leads_requested]} leads"}]
                                            })

    paypal.create

    link = paypal
    .links
    .select { |x| x.rel == 'approval_url' }
    .first

    {payment_url: link.href, payment_id: paypal.id}
  end

  def charge(payment_id, payer_id)

    paypal = PayPal::SDK::REST::Payment.new
    paypal.id = payment_id

    payment_execution = PayPal::SDK::REST::PaymentExecution.new({payer_id: payer_id})
    p paypal.execute(payment_execution)

  end

  def refund(amount)

  end

end