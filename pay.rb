require 'rest_client'
require 'typhoeus'

hash = {
    dc_logon: 'pj-ql-01',
    dc_password: 'pj-ql-01p',
    dc_name: 'David',
    dc_first_name: 'David',
    dc_last_name: 'MZ',
    dc_number: '4444333322221111',
    dc_expiration_month: '1',
    dc_expiration_year: '15',
    dc_transaction_amount: '100',
    dc_transaction_type: 'AUTHORIZATION_CAPTURE',
    dc_verification_number: '999'
}

result = Typhoeus.post "https://www.payjunctionlabs.com/quick_link", ssl_verifypeer: true, ssl_verifyhost: 2, body: hash

puts Hash[result.response_body
     .split(/\u001C/)
     .map {|x| x.split('=')}]

