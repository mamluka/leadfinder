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

  get 'active-plan' do

  end
end