require 'redis'

def gen_redis_proto(*cmd)
  proto = ''
  proto << '*'+cmd.length.to_s+"\r\n"
  cmd.each { |arg|
    proto << '$'+arg.to_s.bytesize.to_s+"\r\n"
    proto << arg.to_s+"\r\n"
  }
  proto
end

File.open(ARGV[0]).each do |line|
  line = line.delete("\n")
  STDOUT.write(gen_redis_proto('SET', line, '1'))
end

