class PayJunction
  def initialize
    @response_codes = {
        '00' => 'Transaction was approved.',
        '85' => 'Transaction was approved.',
        'FE' => 'There was a format error with your Trinity Gateway Service (API) request.',
        'AE' => 'Address verification failed because address did not match.',
        'ZE' => 'Address verification failed because zip did not match.',
        'XE' => 'Address verification failed because zip and address did not match.',
        'YE' => 'Address verification failed because zip and address did not match.',
        'OE' => 'Address verification failed because address or zip did not match..',
        'UE' => 'Address verification failed because cardholder address unavailable.',
        'RE' => 'Address verification failed because address verification system is not working.',
        'SE' => 'Address verification failed because address verification system is unavailable.',
        'EE' => 'Address verification failed because transaction is not a mail or phone order_emails.',
        'GE' => 'Address verification failed because international support is unavailable.',
        'CE' => '',
        'ed' => 'because CVV2/CVC2 code did not match.',
        'NL' => 'Aborted because of a system error, please try again later.',
        'AB' => 'Aborted because of an upstream system error, please try again later.',
        '04' => 'Declined. Pick up card.',
        '07' => 'Declined. Pick up card (Special Condition).',
        '41' => 'Declined. Pick up card (Lost).',
        '43' => 'Declined. Pick up card (Stolen).',
        '13' => 'Declined because of the amount is invalid.',
        '14' => 'Declined because the card number is invalid.',
        '80' => 'Declined because of an invalid date.',
        '05' => 'Declined. Do not honor.',
        '51' => 'Declined because of insufficient funds.',
        'N4' => 'Declined because the amount exceeds issuer withdrawal limit.',
        '61' => 'Declined because the amount exceeds withdrawal limit.',
        '62' => 'Declined because of an invalid service code (restricted).',
        '65' => 'Declined because the card activity limit exceeded.',
        '93' => 'Declined because there a violation (the transaction could not be completed).',
        '06' => 'Declined because address verification failed.',
        '54' => 'Declined because the card has expired.',
        '15' => 'Declined because there is no such issuer.',
        '96' => 'Declined because of a system error.',
        'N7' => 'Declined because of a CVV2/CVC2 mismatch.',
        'M4' => 'Declined.',
        'DT' => 'Duplicate Transaction.',
    }
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
        dc_logon: 'pj-ql-01',
        dc_password: 'pj-ql-01p',
        dc_name: first_name,
        dc_first_name: first_name,
        dc_last_name: last_name,
        dc_number: cc_number,
        dc_expiration_month: cc_month,
        dc_expiration_year: cc_year,
        dc_transaction_amount: amount,
        dc_transaction_type: 'AUTHORIZATION_CAPTURE',
        dc_verification_number: cc_ccv
    }

    p hash

    result = Typhoeus.post "https://www.payjunctionlabs.com/quick_link", ssl_verifypeer: true, ssl_verifyhost: 2, body: hash

    parsed_result = Hash[result.response_body
                         .split(/\u001C/)
                         .map { |x| x.split('=') }]

    is_success = parsed_result['response_code'] == '00' || parsed_result['response_code'] == '05'

    {success: is_success,
     response_message: parsed_result['response_message'],
     transaction_id: parsed_result['transaction_id'],
     approval_code: parsed_result['approval_code'],
     response_code_message: @response_codes[parsed_result['response_code']],
     amout: amount
    }

  end
end