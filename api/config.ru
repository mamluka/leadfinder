require 'rack'

require File.expand_path('../search/search.rb', __FILE__)
require File.expand_path('../facets/facets.rb', __FILE__)
require File.expand_path('../leads/leads.rb', __FILE__)
require File.expand_path('../buy/buy.rb', __FILE__)

map '/leads' do
  run Leads
end

map '/facets' do
  run Facets
end

map '/buy' do
  run Buy
end
