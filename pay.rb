require_relative 'api/buy/payjunction'

pay_junction = PayJunction.new

var = {
    first_name: 'david',
    last_name: 'mz',
    cc_number: '44443333212221111',
    cc_year: '2012',
    cc_month: '112',
    cc_ccv: '999',
    amount: 10000
}

p pay_junction.charge var