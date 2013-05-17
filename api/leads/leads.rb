require 'rack/cors'
require 'tire'
require_relative '../core/queries'
require_relative '../core/pricing'

class Leads < Grape::API
  format :json

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :options, :put, :post]
    end
  end

  post :total do
    params.delete(:route_info)

    query = Queries.new
    pricing = Pricing.new

    s = query.count_leads params

    {total: s.total, pricePerLead: pricing.get_price_for_count(s.total, params)}
  end
end
