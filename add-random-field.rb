require 'tire'
require 'digest/md5'

phones = Array.new
start_end = Time.new

logger = Logger.new('random-sort-update.log')
counter = 0

File.open(ARGV[0]).each do |phone|
  phones << phone.delete("\n")

  counter = counter + 1

  if phones.length % 10000 == 0

    docs = phones

    update_docs = docs.map { |x|
      {
          id: Digest::MD5.hexdigest(x),
          type: 'household',
          script: 'ctx._source.random_sort = round(random()*100000000)'
      }
    }


    s = Tire.index 'leads' do
      bulk :update, update_docs
    end

    logger.info "Took #{Time.new - start_end}, we processed #{counter}"
    start_end = Time.new

    phones.clear
  end

end