require 'tire'
require 'rack/cors'
require 'csv'

class Download < Grape::API
  content_type :csv, 'text/csv'

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :options, :put, :post]
    end
  end

  get :all do
    params.delete(:route_info)
    params.delete(:format)

    current_facets = params

    start_time = Time.now

    s = Tire.search 'leads' do
      query do
        boolean do
          current_facets.each { |k, v| must { string "#{k}:#{v}" } }
        end
      end

      fields :last_name, :address, :state, :city, :telephone_number

      size 100000
    end

    p "the time took to get the data #{Time.now - start_time}"

    start_time = Time.now
    CSV.generate do |csv|
      csv << ['Last Name', 'Address', 'State', 'City', 'Phone']

      s.results.each do |x|
        csv << [x.last_name, x.address, x.state, x.city, x.telephone_number]
      end

      p "Time it took to write the csv is #{Time.now-start_time}"
    end
  end


end