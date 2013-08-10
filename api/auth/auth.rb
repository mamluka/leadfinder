require 'sinatra/base'
require 'omniauth'
require 'omniauth-facebook'
require 'omniauth-linkedin'
require 'omniauth-google-oauth2'
require 'securerandom'

class Auth < Sinatra::Base
  use Rack::Session::Cookie, :secret => 'my-secret'

  use OmniAuth::Builder do
    provider :facebook, '290594154312564', 'a26bcf9d7e254db82566f31c9d72c94e'
    provider :linkedin, 'an9enpnvvp63', 'TErWdwMkcYJ6X8l9'
    provider :google_oauth2, '291055324745.apps.googleusercontent.com', 'Xt_4iAAmoUiI-mRDQA_bZpr6'
  end

  get '/auth/:provider/callback' do
    auth = request.env['omniauth.auth']
    user_id = auth['uid']

    session[:user_id] = user_id
  end

  get '/info' do
    session[:user_id]
  end


end