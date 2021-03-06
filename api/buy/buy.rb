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
require_relative 'paypal'
require_relative 'create-csv-for-customer'
require_relative '../../emails/mail_base'

$config = JSON.parse(File.read(File.dirname(__FILE__) + '/../../config/auth.json'), symbolize_names: true)

class Buy < Grape::API
  format :json

  use Rack::Session::Cookie, :secret => $config[:cookieSecret]

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :options, :put, :post]
    end
  end

  helpers do
    def save_order(order)
      order.delete(:ccNumber)

      json_order = JSON.generate(order)
      filename = File.dirname(__FILE__) + "/orders/#{order[:first_name]}-#{order[:last_name]}-#{Time.now} + #{order[:id]}.json"
      File.open(filename, 'w') { |file| file.write(json_order) }
    end

    def get_paypal_urls
      config = JSON.parse(File.read(File.dirname(__FILE__) + '../../config/buy.json'), symbolize_names: true)

      {approve_url: config[:pp_approve_url], cancel_url: config[:pp_cancel_url]}
    end

    def count_leads(facets)
      query = Queries.new
      query.count_leads(facets).total
    end

    def calculate_charge_amount(count, facets, number_of_leads_requested)
      pricing = Pricing.new
      number_of_leads_requested * pricing.get_price_for_count(count, facets) / 100
    end

    def process_order(order_hash)
      require_relative '../core/queue'

      Backburner.configure do |config|
        config.respond_timeout = 3600
      end

      job_hash = {
          name: order_hash[:name],
          order_id: order_hash[:order_id],
          user_id: order_hash[:user_id]}

      Backburner.enqueue CreateCsvForCustomer, order_hash[:email], order_hash[:number_of_leads_requested], order_hash[:facets], job_hash

      OrderEmails.order_placed(order_hash[:email], job_hash[:name], job_hash[:order_id]).deliver
    end

  end


  post 'buy-using-payjunction' do

    number_of_leads_requested = params[:howManyLeads].to_i
    facets =JSON.parse(params[:facets])

    count = count_leads(facets)
    amount = calculate_charge_amount(count, facets, number_of_leads_requested)

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


    hash[:amount] = amount
    hash[:number_of_leads_requested] = number_of_leads_requested
    hash[:count] = count
    hash[:facets] = facets
    hash[:order_id] = SecureRandom.uuid

    result = pay_junction.charge(hash)
    p result
    #remove this when we have a good sample giver
    if result[:success] || params[:ccNumber] == '378282246310005'

      order_hash = {
          name: "#{params[:firstName]} #{params[:lastName]}",
          order_id: hash[:order_id],
          user_id: params[:userId],
          email: params[:email],
          number_of_leads_requested: number_of_leads_requested,
          facets: facets
      }

      process_order order_hash

      response = {
          success: true,
          amount: amount,
          orderId: hash[:order_id]
      }
    else
      if result[:bad_request]
        response = {
            success: false,
            error_message: result[:errors].first,
            amount: result[:amount]
        }
      else
        response = {
            success: false,
            error_message: result[:errors],
            amount: result[:amount]
        }

      end

    end

    hash[:response] = response

    save_order hash

    response
  end

  options 'unlimited' do
  end

  post 'unlimited' do
    session = env['rack.session']

    auth = Authentication.new

    facets =JSON.parse(params[:facets])
    number_of_leads_requested = params[:howManyLeads].to_i
    count = count_leads(facets)

    if auth.authenticated?(session) && auth.has_plan?(session, 'unlimited') && count >= number_of_leads_requested

      order_hash = {
          name: "#{params[:firstName]} #{params[:lastName]}",
          order_id: SecureRandom.uuid,
          user_id: params[:userId],
          email: params[:email],
          number_of_leads_requested: number_of_leads_requested,
          facets: facets
      }

      process_order order_hash
      save_order order_hash

      {success: true}
    else
      {success: false}
    end

  end

  get 'buy-using-paypal' do

    how_many_leads = params[:howManyLeads]

    paypal_urls = get_paypal_urls

    query = Queries.new
    pricing = Pricing.new

    facets = JSON.parse(params[:facets])

    count = query.count_leads(facets).total
    number_of_leads_requested = how_many_leads.to_f
    amount = number_of_leads_requested * pricing.get_price_for_count(count, facets) / 100

    paypal = Paypal.new

    result = paypal.get_charge_link({
                                        amount: amount,
                                        number_of_leads_requested: how_many_leads,
                                        approve_url: paypal_urls[:approve_url],
                                        cancel_url: paypal_urls[:cancel_url]

                                    })

    {redirectUrl: result[:payment_url], paymentId: result[:payment_id]}
  end

  post 'paypal-payment-execute' do
    payer_id = params[:payerId]
    payment_id = params[:paymentId]

    amount = count_leads(JSON.parse(params[:facets]), params[:howManyLeads])

    paypal = Paypal.new
    begin
      paypal.charge(payment_id, payer_id)


      {success: true}
    rescue
      {success: false}
    end

  end


end
