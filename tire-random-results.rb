require 'tire'
require 'securerandom'

s = Tire.search 'leads' do
  query do
    all
  end

  sort do
    by :_script, {
        script: "org.elasticsearch.common.Digest.md5Hex(doc['_id'].value + salt)",
        type: 'string',
        params: {
            salt: SecureRandom.uuid
        }
    }

  end
end

p s.to_json

p s.results.length