require 'tire'
require 'json'
require 'rest-client'

Signal.trap('PIPE', 'EXIT')

json_parse = JSON.parse(File.read(ARGV[0]), symbolize_names: true)
json_parse = json_parse.merge({fields: ['ids']})
begin
  s = RestClient.post 'http://localhost:9200/leads/household/_search', json_parse.to_json, :content_type => :json, :accept => :json
  s = JSON.parse(s, symbolize_names: true)
rescue => e
  p e.response
end

count = s[:hits][:total]

chunk_size = ARGV[1]
json_parse = json_parse.merge({size: chunk_size})
total_ids = 0

while total_ids < count

  json_parse = json_parse.merge({from: total_ids})
  begin
    s = RestClient.post 'http://localhost:9200/leads/household/_search', json_parse.to_json, :content_type => :json, :accept => :json
    s = JSON.parse(s, symbolize_names: true)
    total_ids = total_ids + s[:hits].length


    s[:hits][:hits].each{ |x|  $stdout.write  x[:_id] + "\n"}

  rescue => e
    p e
  end

end
