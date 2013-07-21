require 'rack/cors'
require 'mysql2'

class Users< Grape::API
  format :json

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :options, :put, :post]
    end
  end

  get 'check-user-state' do

    session_id = params[:sessionId]

    client = Mysql2::Client.new(:host => "70.87.135.10", :username => "leadfinder", :password => '0953acb', :database => 'marketingdata1')


    results = client.query("SELECT * FROM ptfki_session WHERE session_id='#{session_id}' ")

    results
  end
end