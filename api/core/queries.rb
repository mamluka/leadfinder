require 'tire'

class Queries

  def count_leads(params)
    must_filters = get_must_filters(params)

    s = Tire.search 'leads' do
      query do
        nested :path => 'people' do
          query do
            filtered do
              filter :bool, {:must => must_filters}
            end
          end
        end
      end

      size 0
    end

    p s.to_json

    s.results
  end

  def get_leads(params, size)

    must_filters = get_must_filters(params)

    s = Tire.search 'leads' do
      query do
        nested :path => 'people' do
          query do
            filtered do
              filter :bool, {:must => must_filters}
            end
          end
        end
      end

      sort do
        by :_script, {
            script: "org.elasticsearch.common.Digest.md5Hex(doc['household_id'].value + salt)",
            type: 'string',
            params: {
                salt: SecureRandom.uuid
            }
        }

      end

      size size
    end

    p s.to_json

    s.results
  end

  def get_must_filters(params)

    terms = Hash.new
    ranges = Hash.new
    multi_term = Hash.new

    params.each do |k, v|
      if v.to_s.include?('-')
        ranges[k]=v
        next
      end

      if v.to_s.include?(',')
        multi_term[k]=v
        next
      end

      terms[k]=v
    end

    terms.map { |k, v| {:term => {k.to_sym => v}} }
    .concat(multi_term.map { |k, v| {:terms => {k.to_sym => v.split(',')}} })
    .concat(ranges.map { |k, v| {:range => {k.to_sym => {gte: v.split('-')[0], lt: v.split('-')[1]}}} })

  end
end