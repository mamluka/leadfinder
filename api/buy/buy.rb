require 'tire'
require 'rack/cors'
require 'typhoeus'
require 'json'
require 'backburner'
require 'securerandom'
require 'time'

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

  helpers do
    def save_order(order)
      json_order = JSON.generate(order)
      filename = File.dirname(__FILE__) + "/orders/#{order[:first_name]}-#{order[:last_name]}-#{Time.now} + #{SecureRandom.uuid}.json"
      File.open(filename, 'w') { |file| file.write(json_order) }
    end
  end


  post :buy do

    query = Queries.new
    pricing = Pricing.new

    facets = JSON.parse(params[:facets])

    count = query.count_leads(facets).total
    number_of_leads_requested = params[:howManyLeads].to_f
    amount = number_of_leads_requested * pricing.get_price_for_count(count, facets)

    pay_junction = PayJunction.new

    hash = {
        first_name: params[:firstName],
        last_name: params[:lastName],
        cc_number: params[:ccNumber],
        cc_year: params[:ccYear],
        cc_month: params[:ccMonth],
        cc_ccv: params[:ccCCV],
        amount: amount
    }

    result = pay_junction.charge(hash)

    hash[:amount] = amount
    hash[:number_of_leads_requested] = number_of_leads_requested
    hash[:count] = count


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

    hash[:response] = response

    save_order hash

    response
  end


end