require 'tire'
require 'logger'

ids = Array.new
start_end = Time.new

logger = Logger.new('update-script-log.log')
counter = 0

chunk_size = 10000

File.open(ARGV[0]).each do |id|
  ids << id.delete("\n")

  counter = counter + 1


  if ids.length % chunk_size == 0

    docs = ids

    update_docs = docs.map { |x|
      {
          id: x,
          type: 'household',
          script: File.read(ARGV[1])
      }
    }


    s = Tire.index 'leads' do
      bulk :update, update_docs
    end

    p s

    bulk_time = Time.new - start_end
    logger.info "Took #{bulk_time}, we processed #{counter} [#{chunk_size/bulk_time}] docs/sec"
    start_end = Time.new

    ids.clear
  end

end