require 'tire'
require 'rack/cors'
require 'typhoeus'
require 'json'
require 'backburner'

require_relative '../core/queries'
require_relative '../core/pricing'
require_relative 'payjunction'
require_relative 'create-csv-for-customer'


class Buy < Grape::API
  format :json

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :options, :put, :post]
    end
  end


  post :buy do

    query = Queries.new
    pricing = Pricing.new

    facets = JSON.parse(params[:facets])

    count = query.count_leads(facets).total
    number_of_leads_requested = params[:howManyLeads].to_f

    p number_of_leads_requested

    amount = number_of_leads_requested * pricing.get_price_for_count(count, facets)

    p amount

    pay_junction = PayJunction.new

    result = pay_junction.charge({
                                     first_name: params[:firstName],
                                     last_name: params[:lastName],
                                     cc_number: params[:ccNumber],
                                     cc_year: params[:ccYear],
                                     cc_month: params[:ccMonth],
                                     cc_ccv: params[:ccCCV],
                                     amount: amount
                                 })

    if result[:success]

      require_relative '../core/queue'

      Backburner.enqueue CreateCsvForCustomer, params[:email], number_of_leads_requested, facets

      response = {
          success: true
      }
    else
      response = {
          success: false,
          error_message: result[:response_code_message],
          amount: result[:amount]
      }
    end

    response
  end
end