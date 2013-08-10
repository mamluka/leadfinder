require 'rack'

require File.expand_path('../search/search.rb', __FILE__)
require File.expand_path('../facets/facets.rb', __FILE__)
require File.expand_path('../leads/leads.rb', __FILE__)
require File.expand_path('../buy/buy.rb', __FILE__)
require File.expand_path('../upload/upload.rb', __FILE__)
require File.expand_path('../upload/upload-new.rb', __FILE__)
require File.expand_path('../users/users.rb', __FILE__)
require File.expand_path('../auth/auth.rb', __FILE__)

map '/leads' do
  run Leads
end

map '/facets' do
  run Facets
end

map '/buy' do
  run Buy
end

map '/upload' do
  run Uploads
  end

map '/upload-new' do
  run UploadsNew
end

map '/users' do
  run Users
end

map '/user' do
  run Auth
end
