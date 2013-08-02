require 'tire'
require 'digest/md5'

phones = Array.new
start_end = Time.new

Tire.configure { logger 'elasticsearch.log', :level => 'debug' }

File.open(ARGV[0]).each do |phone|
  phones << phone.delete("\n")

  if phones.length % 1000 == 0

    docs = phones
    .group_by { |x| x.split(':')[0] }
    .map { |k, v| v.inject({failed: 0, connected: 0, seconds_30: 0, seconds_300: 0}.merge({phone: k})) { |hash, p|
      cdr_type = p.split(':')[1].to_i

      case cdr_type
        when 0
          hash[:failed] = hash[:failed] + 1
        when 1
          hash[:connected] = hash[:connected] + 1
        when 2
          hash[:seconds_30] = hash[:seconds_30] + 1
        when 3
          hash[:seconds_300] = hash[:seconds_300] + 1
        else
          hash
      end

      hash

    } }

    update_docs = docs.map { |x| {
        id: Digest::MD5.hexdigest(x[:phone]),
        type: 'household',
        script: 'if (ctx._source.containsKey("cdr_failed")) { ctx._source.cdr_failed +=cdr_failed } else { ctx._source.cdr_failed =cdr_failed }; if (ctx._source.containsKey("cdr_connected")) { ctx._source.cdr_connected +=cdr_connected } else { ctx._source.cdr_connected = cdr_connected  }; if (ctx._source.containsKey("cdr_seconds_30")) { ctx._source.cdr_seconds_30 +=cdr_seconds_30 } else { ctx._source.cdr_seconds_30 = cdr_seconds_30 }; if (ctx._source.containsKey("cdr_seconds_300")) { ctx._source.cdr_seconds300 +=cdr_seconds_300 } else { ctx._source.cdr_seconds_300 = cdr_seconds_300 };',
        params: {
            cdr_failed: x[:failed],
            cdr_connected: x[:connected],
            cdr_seconds_30: x[:seconds_30],
            cdr_seconds_300: x[:seconds_300],
        }
    }
    }

    s = Tire.index 'leads' do

      bulk :update, update_docs

    end

    File.open('response.json', 'a') { |f| f.write(s.to_json) }

    p "Took #{Time.new - start_end}"
    start_end = Time.new

    phones.clear
  end

end