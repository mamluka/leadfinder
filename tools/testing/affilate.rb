require 'rest-client'
require 'json';

auth_json = JSON.generate({
                              C: "Gpf_Api_AuthService",
                              M: "authenticate",
                              fields: [["name", "value", "values", "error"], ["username", "jayw@flowmediacorp.com", "null", ""], ["password", "dataflow1", "null", ""], ["roleType", "M", "null", ""], ["isFromApi", "Y", "null", ""], ["apiVersion", "c278cce45ba296bc421269bfb3ddff74", "null", ""]]})

response = RestClient.post 'http://market.marketing-data.net/scripts/server.php', D: auth_json

response = JSON.parse(response, symbolize_names: true)
auth_token = response[:fields].select { |x| x[0] == 'S' }.first[1]

#create transaction

trans_json = JSON.generate(
    {C: "Gpf_Rpc_Server",
     M: "run",
     requests: [{C: "Pap_Merchants_Transaction_TransactionsForm",
                 M: "add",
                 fields: [["name", "value"],
                          ["Id", ""],
                          ["rstatus", "A"],
                          ["dateinserted", "2013-06-28 07:42:39"],
                          ["totalcost", ""],
                          ["channel", ""],
                          ["fixedcost", ""],
                          ["multiTier", "N"],
                          ["commtypeid", "1537b2cc"],
                          ["bannerid", ""],
                          ["payoutstatus", "U"],
                          ["countrycode", ""],
                          ["userid", "11111111"],
                          ["campaignid", "8a8391f4"],
                          ["parenttransid", ""],
                          ["commission", "100"],
                          ["tier", "1"],
                          ["commissionTag", "Commissions are computed automatically"],
                          ["orderid", ""],
                          ["productid", ""],
                          ["data1", ""],
                          ["data2", ""],
                          ["data3", ""],
                          ["data4", ""],
                          ["data5", ""],
                          ["trackmethod", "U"],
                          ["refererurl", ""],
                          ["ip", ""],
                          ["firstclicktime", ""],
                          ["firstclickreferer", ""],
                          ["firstclickip", ""],
                          ["firstclickdata1", ""],
                          ["firstclickdata2", ""],
                          ["lastclicktime", ""],
                          ["lastclickreferer", ""],
                          ["lastclickip", ""],
                          ["lastclickdata1", ""],
                          ["lastclickdata2", ""],
                          ["systemnote", ""],
                          ["merchantnote", ""]]}],
     S: auth_token}
)

response = RestClient.post 'http://market.marketing-data.net/scripts/server.php', D: trans_json
