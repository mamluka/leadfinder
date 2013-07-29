require 'redis'

redis = Redis.new

phones_to_get = Array.new
counter = 0
start_time = Time.now

steps = 1000000

File.open(ARGV[0]).each do |line|

  if phones_to_get.length == steps

    counter = counter + steps

    s = redis.pipelined do
      phones_to_get.each { |x| redis.get x.split(',')[1] }
    end
    ok_phones = Array.new
    s.each_index { |i| ok_phones << phones_to_get[i] if s[i] == '1' }

    p "Took #{Time.now-start_time} for this cycle, total read #{counter}"

    File.open(ARGV[1], 'a') { |f| ok_phones.each { |x| f.write(x) } }

    phones_to_get.clear
    start_time = Time.now
  end

  phones_to_get << line
end




