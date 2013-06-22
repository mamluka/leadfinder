require_relative 'api/buy/create-csv-for-customer'

CreateCsvForCustomer.perform 'david.mazvovsky@gmail.com', 100, {gender: 'm,u', has_telephone_number: 'true', income_estimated_household: '20000-50000', pool: 'false'},{order_id:'david',name:'coolio'}