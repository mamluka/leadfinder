require 'sinatra/base'
require 'omniauth'
require 'omniauth-facebook'
require 'omniauth-linkedin'
require 'omniauth-google-oauth2'
require 'securerandom'
require 'json'

require_relative '../core/authentication'

$config = JSON.parse(File.read(File.dirname(__FILE__) + '/../../config/auth.json'), symbolize_names: true)

OmniAuth.config.full_host = $config[:callback_base_url]

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
    session[:first_name] = auth['info']['first_name']
    session[:last_name] = auth['info']['last_name']

    redirect to($config[:domain])
  end

  get '/permissions' do
    content_type :json
    cache_control :no_cache, :max_age => 0

    auth = Authentication.new
    is_authenticated = auth.authenticated? session
    user = auth.get_user_from_session(session)

    {found: !user.nil?,
     authenticated: is_authenticated,
     plan: user.nil? ? 'regular' : user.plan,
     email: user.nil? ? '' : user.email,
     firstName: session[:first_name],
     lastName: session[:last_name]}.to_json

  end

  get '/logout' do
    user_id = session[:user_id]
    session.clear

    {email: user_id}.to_json
  end

end