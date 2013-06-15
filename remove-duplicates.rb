require 'tire'

module RestClient
  def self.delete_with_payload(url, payload, headers={}, &block)
    Request.execute(:method => :delete, :url => url, :payload => payload, :headers => headers, &block)
  end
end

module Tire
  module HTTP
    module Client
      class RestClient
        # Allow data to be passed to delete
        def self.delete(url, data = nil)
          if data
            perform ::RestClient.delete_with_payload(url, data)
          else
            perform ::RestClient.delete(url)
          end
        rescue *ConnectionExceptions
          raise
        rescue ::RestClient::Exception => e
          Response.new e.http_body, e.http_code
        end
      end
    end
  end

  class Index
    # Removes items which match the query
    #
    # @see http://www.elasticsearch.org/guide/reference/api/delete-by-query.html
    # @example
    # {
    #   "bool": {
    #     "must": {
    #       "term":{"user_id":1}
    #     },
    #     "must": {
    #       "terms":{"uid":[12972, 12957, 12954]}
    #     }
    #   }
    # }
    def delete_by_query(&blk)
      raise ArgumentError.new('block not supplied') unless block_given?
      query = Tire::Search::Query.new(&blk)
      Configuration.client.delete("#{Configuration.url}/#{@name}/_query", query.to_json)
    end
  end
end

s = Tire.search 'leads' do
  facet 'phones' do
    terms :telephone_number, size: 10000

  end
end

remove_phones = s.results.facets['phones']['terms'].take_while { |f| f['count'] > 1 }.map { |f| f['term'] }

remove_phones.each_slice(1024) { |s|
  s = Tire.index 'leads' do
    delete_by_query do
      terms :telephone_number, s
    end
  end
}

