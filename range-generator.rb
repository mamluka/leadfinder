require 'json'

start = ARGV[0].to_i
stop = ARGV[1].to_i
jump = ARGV[2].to_f
facet_id = ARGV[3]

output = Array.new

Range.new(0, (stop-start)/jump).each do |x|
  value = (start + x*jump).to_f.to_s
  output << {id: facet_id, value: value, text: value}
end

puts JSON.generate(output)
