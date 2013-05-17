require 'grape'
require 'tire'
require 'rack/cors'

require_relative 'facets_text_translator'

class Facets < Grape::API

  format :txt
  content_type :txt, 'application/json'

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :options, :put, :post]
    end
  end

  helpers do
    def api_response(search_result)
      facets = Hash.new

      search_result.results.facets.each do |k, v|
        facet_id= k.to_s

        facet = v['terms'].map do |t|
          value = t['term']
          text = FacetsTextTranslator.new.translate k, value
          {id: facet_id, value: value, text: text}
        end
        facet.sort! do |x, y|
          x[:value].to_s <=> y[:value].to_s
        end

        if is_i?(facet.last[:value])
          facet.last[:value] = facet.last[:value].to_i * 2
        end

        facets[facet_id]=facet
      end

      facets
    end

    def is_i?(str)
      Float(str) != nil rescue false
    end

    def get_facets_list
      facet_array = %w(state income_estimated_household net_worth language home_owner credit_rating exact_age home_market_value mortgage_purchase_date_ccyymmdd purchase_second_mortgage_interest_rate most_recent_mortgage_date purchase_mortgage_date most_recent_mortgage_loan_type second_most_recent_mortgage_loan_type purchase_1st_mortgage_loan_type purchase_second_mortgage_loan_type most_recent_lender most_recent_lender_name second_most_recent_lender second_most_recent_lender_name  purchase_lender purchase_lender_name most_recent_mortgage_interest_rate_type purchase_1st_mortgage_interest_rate_type second_most_recent_mortgage_interest_rate_type most_recent_mortgage_interest_rate purchase_1st_mortgage_interest_rate most_recent_mortgage_interest_rate purchase_second_mortgage_interest_rate mortgage_purchase_price most_recent_mortgage_amount second_most_recent_mortgage_amount purchase_1st_mortgage_amount purchase_second_mortgage_amount)
    end
  end


  get :all do

    facets_list = get_facets_list.uniq
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

  get 'all-cached' do

    File.read(File.dirname(__FILE__) + '/all-facets.json')
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