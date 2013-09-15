require 'json'

from = ARGV[0].to_i
to = ARGV[1].to_i
step = ARGV[2].to_i
facet = ARGV[3]


facets = Array.new
(from..to).step(step).each { |x|
  facets << {
      id: facet,
      text: x,
      value: x
  }
}

$stdout.puts JSON.pretty_generate(facets)



