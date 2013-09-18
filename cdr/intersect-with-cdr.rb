require 'redis'
require 'logger'

redis = redis = Redis.new(:host => "10.0.1.1", :port => ENV['CDR_REDIS_PORT'].nil? ? 6379 : ENV['CDR_REDIS_PORT'].to_i)

phones_to_get = Array.new
counter = 0
start_time = Time.now

steps = 1000000

logger = Logger.new 'log-intersect-with-cdr.log'

File.open(ARGV[0]).each do |line|

  if phones_to_get.length == steps

    counter = counter + steps

    s = redis.pipelined do
      phones_to_get.each { |x| redis.get x }
    end
    ok_phones = Array.new
    s.each_index { |i| ok_phones << phones_to_get[i] if s[i] == '1' }

    logger.info "Took #{Time.now-start_time} for this cycle, total read #{counter}"

    ok_phones.each { |x| $stdout.puts x } 

    phones_to_get.clear
    start_time = Time.now
  end

  phones_to_get << line.strip
end
