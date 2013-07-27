require 'tire'
require 'csv'
require 'time'

Tire.index 'cdr2' do
  delete
end

cdrs = Array.new
start_time = Time.now
CSV.foreach(ARGV[0] ,{:headers => false, :col_sep => ','}) do |line|

  cdrs << {
      phone: line[1],
      time: Time.parse(line[0]).to_i,
      duration: line[3].to_i,
      status: line[2].to_i
  }

  if cdrs.length > 50000

    Tire.index 'cdr2' do

      #bulk :update, cdrs.map { |x| {
      #    id: x[:phone],
      #    script: 'ctx._source.call +=call',
      #    params: {
      #        call: {
      #            time: x[:time],
      #            duration: x[:duration],
      #            status: x[:status]
      #        }
      #
      #    },
      #    upsert: {
      #        call: [{
      #                   time: x[:time],
      #                   duration: x[:duration],
      #                   status: x[:status]
      #               }]
      #    }
      #}
      #}
      import cdrs
    end

    cdrs = Array.new

    p "Did 5000 in #{Time.now-start_time} seconds"
    start_time = Time.now
  end
end

Tire.index 'cdr' do

  bulk :update, cdrs.map { |x| {
      id: x[:phone],
      script: 'ctx._source.call +=call',
      params: {
          call: {
              time: x[:time],
              duration: x[:duration],
              status: x[:status]
          }

      },
      upsert: {
          call: [{
                     time: x[:time],
                     duration: x[:duration],
                     status: x[:status]
                 }]
      }
  }
  }
end

cdrs = Array.new

p "Did 5000 in #{Time.now-start_time} seconds"
start_time = Time.now
