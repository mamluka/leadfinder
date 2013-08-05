require 'grape'


class Buy < Grape::API
  format :json

  use Rack::Session::Cookie
  use OmniAuth::Strategies::Developer
end