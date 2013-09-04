require_relative '../../api/buy/create-csv-for-customer'

CreateCsvForCustomer.perform 'david@gmail.com', 100, {"has_telephone_number"=>"true", "state"=>"nv,nj,ny"}, {'name' => "David MZ", 'order_id' => "7e840afe-45ad-4243-addd-dd6545cd14892", 'user_id' => "dea15c0556ffxx8f75c5fd091b"}