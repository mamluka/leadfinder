require 'json'
require 'typhoeus'

class PayJunction
  def initialize
    @config = JSON.parse(File.read(File.dirname(__FILE__)+'/config.json'))
  end

  def charge(details)

    first_name = details[:first_name]
    last_name= details[:last_name]
    cc_number =details[:cc_number]
    cc_year =details[:cc_year]
    cc_month = details[:cc_month]
    cc_ccv = details[:cc_ccv]
    amount = details[:amount].to_f.round(2)

    hash = {
        userpwd: "#{@config['pj_username']}:#{@config['pj_password']}",
        body: {
            billingFirstName: first_name,
            billingLastName: last_name,
            cardNumber: cc_number,
            cardExpMonth: cc_month,
            cardExpYear: cc_year,
            amountBase: amount,
            action: 'charge',
            cvv: 'off',
            cardCvv: cc_ccv
        }
    }

    call_result = Typhoeus.post @config['pj_url'], hash

    result = JSON.parse(call_result.body, symbolize_names: true)

    if result.has_key?(:errors)
      {
          success: false,
          bad_request: true,
          errors: result[:errors].map { |x| x[:message] }
      }
    else
      is_success = result[:response][:approved]

      if is_success
        {
            success: true,
            response_message: result[:response][:message],
            transaction_id: result[:transactionId],
            approval_code: result[:response][:processor][:approvalCode],
            amount: result[:amountTotal]
        }
      else
        {
            success: false,
            bad_request:false,
            message: result[:response][:message]
        }
      end
    end
  end

  def refund(amount)

  end
end
