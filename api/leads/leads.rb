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


  get :total do
    params.delete(:route_info)

    terms = Hash.new
    ranges = Hash.new
    multi_term = Hash.new

    params.each do |k, v|
      ranges[k]=v if v.include?('-')
      multi_term[k]=v if v.include?(',')
      terms[k]=v
    end

    s = Tire.search 'leads' do
      query do
        constant_score do
          terms.each { |k, v| filter :term, {k.to_sym => v} }
          multi_term.each { |k, v| filter :terms, {k.to_sym => v.split(',')} }
          ranges.each { |k, v| filter :range, k.to_sym => {gte: v.split('-')[0], lt: v.split('-')[1]} }
        end
      end

    end

    p s.to_json

    {total: s.results.total}
  end
end
