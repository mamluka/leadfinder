require 'grape'
require 'tire'
require 'rack/cors'

class Facets < Grape::API

  format :json

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :options, :put, :post]
    end
  end

  helpers do
    def api_response(search_result)
      facets = Hash.new
      search_result.results.facets.each { |k, v| facets[k.to_s] = v['terms'].map { |t| {id: t['term'], text: t['term'], count: t['count']} } }

      facets
    end

    def get_facets_list
      facet_array = %w(state income_estimated_household net_worth language home_owner credit_rating exact_age gender has_telephone_number tennis golf snow_skiing)
    end
  end


  get :all do

    facets_list = get_facets_list
    s = Tire.search do

      query do
        string '*'
      end

      facets_list.each do |facet|
        facet facet, :global => true do
          terms facet.to_s, size: 100
        end
      end
    end

    api_response(s)
  end

  get 'get-available' do

    params.delete(:route_info)
    current_facets = params
    facets_list = get_facets_list

    s = Tire.search do

      query do
        boolean do
          current_facets.each { |k, v| must { string "#{k}:#{v}" } }
        end
      end

      facets_list.each do |facet|
        facet facet do
          terms facet.to_s, size: 100
        end
      end
    end

    api_response(s)
  end
end