require 'tire'
require 'digest/md5'

phones = Array.new
start_end = Time.new

File.open(ARGV[0]).each do |phone|
  phones << phone.delete("\n")

  if phones.length % 10000 == 0

    docs = phones

    update_docs = docs.map { |x| {
        id: Digest::MD5.hexdigest(x),
        type: 'household',
        doc: {
            random_sort: Random.rand(6000000)
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