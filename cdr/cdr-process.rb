require 'csv'
require 'redis'
counter = 0

redis = Redis.new

start_time = Time.new

rows = Array.new
File.open(ARGV[1], 'a') do |f|

  CSV.foreach(ARGV[0]) do |row|
    counter = counter +1

    status = row[2].to_i
    duration = row[3].to_i

    if status == 4
      f.write(row[1] + ":0\n")
      next
    end

    if status < 4
      f.write(row[1] + ":1\n")
    end

    if status == 1 && duration.to_i > 30 && duration.to_i <= 300
      f.write(row[1] + ":2\n")
    end

    if status == 1 && duration.to_i > 300
      f.write(row[1] + ":3\n")
    end

    if counter % 100000 == 0
      p "We processed #{counter} at #{Time.new - start_time} seconds"
      start_time = Time.new
    end
  end

end