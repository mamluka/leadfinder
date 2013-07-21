require 'rack/cors'
require 'json'
require 'securerandom'
require 'ptools'


class UploadsNew < Grape::API
  format :json

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :options, :put, :post]
    end
  end

  post 'suppression-list' do

    file = params[:file]
    user_id = params[:userId]

    tempfile = file[:tempfile]


    dir_path = File.dirname(__FILE__) + '/../../users/' + user_id

    unless Dir.exists?(dir_path)
      Dir.mkdir(dir_path)
    end

    permanent_file_path = dir_path + '/' + SecureRandom.uuid

    FileUtils.cp tempfile.path, permanent_file_path

    {isTextFile: !File.binary?(permanent_file_path)}

  end

  options 'suppression-list' do

  end
end
