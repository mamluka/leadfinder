require 'tire'
require 'rack/cors'
require 'csv'

class Download < Grape::API
  content_type :csv, 'text/csv'

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :options, :put, :post]
    end
  end

  get '/csv/:filename' do
    File.read(File.dirname(__FILE__) +'/../../downloads/' + params[:filename])
  end
end