require 'sinatra/base'
require 'omniauth'
require 'omniauth-facebook'
require 'omniauth-linkedin'
require 'omniauth-google-oauth2'
require 'securerandom'
require 'json'

require_relative '../core/orm'

$config = JSON.parse(File.read(File.dirname(__FILE__) + '/config.json'), symbolize_names: true)

class Auth < Sinatra::Base
  use Rack::Session::Cookie, :secret => $config[:cookieSecret]

  use OmniAuth::Builder do
    provider :facebook, $config[:facebook][:key], $config[:facebook][:secret]
    provider :linkedin, $config[:linkedin][:key], $config[:linkedin][:secret]
    provider :google_oauth2, $config[:google_oauth2][:key], $config[:google_oauth2][:secret]
  end

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :options, :put, :post]
    end
  end

  get '/auth/:provider/callback' do
    auth = request.env['omniauth.auth']
    user_id = auth['info']['email']

    session[:user_id] = user_id
  end

  get '/permissions' do
    content_type :json
    cache_control :no_cache,:max_age => 0

    user_id = session[:user_id]

    if not user_id.nil?
      user = User.where(email: user_id).first
      if not user.nil?
        {plan: user.plan, found: true, authenticated: true, email: user.email}.to_json
      else
        {found: false, authenticated: true}.to_json
      end

    else
      {found: false, authenticated: false}.to_json
    end
  end


end