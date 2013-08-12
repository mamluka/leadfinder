require 'grape'
require 'tire'
require 'rack/cors'

class ContactUs < Grape::API

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :options, :put, :post]
    end
  end

  format :json

  post :send do
    ContactUsEmails.contact_form('david.mazvovsky@gmail.com;jayw@flowmediacorp.com', params[:email], params[:message]).deliver!
    'OK'
  end

  options :send do

  end

end