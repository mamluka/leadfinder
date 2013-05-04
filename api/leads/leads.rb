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
    current_facets = params

    s = Tire.search 'leads' do
      query do
        boolean do
          current_facets.each { |k, v| must { string "#{k}:#{v}" } }
        end
      end

      size 0
    end

    {total: s.results.total}
  end

  get :download do
    params.delete(:route_info)
    current_facets = params

    s = Tire.search 'leads' do
      query do
        boolean do
          current_facets.each { |k, v| must { string "#{k}:#{v}" } }
        end
      end

      size Integer::MAX
    end
  end


end