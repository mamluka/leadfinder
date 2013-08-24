require 'mongoid'

Mongoid.load!(File.dirname(__FILE__) + '/mongoid.yml', :development)

class User
  include Mongoid::Document

  field :email, type: String
  field :plan, type: String
end

