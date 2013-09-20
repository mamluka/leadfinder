require 'redis'
require 'logger'


class ProcessCDR
  def initialize
    @redis = Redis.new(:host => "localhost", :port => ENV['CDR_REDIS_PORT'].nil? ? 6379 : ENV['CDR_REDIS_PORT'].to_i)
    @logger = Logger.new 'log-intersect-with-cdr.log'
  end


  def process(phones_to_get)

    start_time = Time.now

    s = @redis.pipelined do
      phones_to_get.each { |x| @redis.get x[:phone] }
    end
    ok_phones = Array.new
    s.each_index { |i| ok_phones << phones_to_get[i] if s[i] == '1' }

    @logger.info "Took #{Time.now-start_time} for this cycle"

    ok_phones.each { |x| $stdout.puts x[:line] }

    phones_to_get.clear
  end
end

steps = 1000000
phones_to_get = Array.new
process = ProcessCDR.new

File.open(ARGV[0]).each do |line|
  line.scan(/\d{10}/).map { |x| {line: line.strip, phone: x} }.each { |x| phones_to_get << x }

  if phones_to_get.length % steps == 0
    process.process(phones_to_get)
  end

end

process.process(phones_to_get)
