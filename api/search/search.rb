require 'grape'
require 'tire'
require 'rack/cors'

class LeadFinderSearch < Grape::API

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :options, :put, :post]
    end
  end

  format :json
  resource :search do
    get :query do
      q = params[:q]
      result = Tire.search 'leads' do
        query do
          string q
        end
      end

      result.results
    end

    options :query do
    end
  end
end
