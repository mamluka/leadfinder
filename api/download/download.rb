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

    terms = Hash.new
    ranges = Hash.new
    multi_term = Hash.new

    start_time = Time.now

    params.each do |k, v|
      if v.include?('-')
        ranges[k]=v
        next
      end

      if v.include?(',')
        multi_term[k]=v
        next
      end

      terms[k]=v
    end

    s = Tire.search 'leads' do
      query do
        constant_score do
          filter :bool, {:must => terms.map { |k, v| {:term => {k.to_sym => v}} }
          .concat(multi_term.map { |k, v| {:terms => {k.to_sym => v.split(',')}} })
          .concat(ranges.map { |k, v| {:range => {k.to_sym => {gte: v.split('-')[0], lt: v.split('-')[1]}}} })}
        end
      end

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