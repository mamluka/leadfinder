require 'rack/cors'
require 'tire'
require 'redis'
require 'digest/md5'

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

    hash = Digest::MD5.hexdigest(params.to_s)
    redis = Redis.new

    total = redis.get hash

    if total.nil?
      s = query.count_leads params
      total = s.total
      redis.set hash, total
    end

    {total: total, pricePerLead: pricing.get_price_for_count(total, params), timestamp: Time.now.to_i}
  end
end
