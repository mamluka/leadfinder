require 'tire'

class Queries

  def count_leads(params)
    must_filters = get_must_filters(params)

    s = Tire.search 'leads' do
      query do
        filtered do
          filter :bool, {:must => must_filters}
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
        filtered do
          filter :bool, {:must => must_filters}
        end
      end

      size size
    end

    s.results
  end

  def get_must_filters(params)

    terms = Hash.new
    ranges = Hash.new
    multi_term = Hash.new

    params.each do |k, v|
      if v.include?('-')
        ranges[k]=v
        next
      end

      if v.include?(',')
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