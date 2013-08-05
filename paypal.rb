require_relative 'api/buy/paypal'

paypal = Paypal.new
#
#paypal.get_charge_link({
#                  amount: 1000,
#                  number_of_leads_requested: 2000
#              })
#

payer_id='FNVE2Z39J9WNE'
payment_id = 'PAY-2NJ13325XW742761BKH7HVZA'

paypal.charge(payment_id,payer_id)





