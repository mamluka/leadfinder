require 'rack/cors'
require 'json'

class Uploads < Grape::API
  content_type :txt, 'text/html'
  formatter :txt, lambda { |object, env|
    config = JSON.parse(File.read(File.dirname(__FILE__)+ '/config.json'))

    "<script>document.domain = '#{config['domain']}'</script>" + JSON.generate(object)
  }

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :options, :put, :post]
    end
  end

  post 'zip-list' do
    file = params[:file]

    zips = Array.new

    f = file[:tempfile].open()
    begin
      f.each do |line|
        zip = line.split(',').first.match(/\d{5}/)
        unless zip.nil?
          zips << zip[0]
        end
        next
      end
    ensure
      f.close
    end

    zips.uniq
  end

  post 'suppression-list' do
    Array.new
  end

  options 'suppression-list' do

  end

end
