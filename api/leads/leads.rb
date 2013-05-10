require 'tire'
require 'rack/cors'

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

    terms = Hash.new
    ranges = Hash.new
    multi_term = Hash.new

    params.each do |k, v|
      if v.include?('-')
        ranges[k]=v
        next
      end

      if v.include?(',')
        multi_term[k]=v
        next
      end

      terms[k]=v
    end

    s = Tire.search 'leads' do
      query do
        constant_score do
          filter :bool, {:must => terms.map { |k, v| {:term => {k.to_sym => v}} }
          .concat(multi_term.map { |k, v| {:terms => {k.to_sym => v.split(',')}} })
          .concat(ranges.map { |k, v| {:range => {k.to_sym => {gte: v.split('-')[0], lt: v.split('-')[1]}}} })}
        end
      end

    end

    p s.to_json

    {total: s.results.total}
  end
end
