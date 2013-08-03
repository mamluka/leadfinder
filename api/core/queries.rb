require 'tire'

class Queries

  def count_leads(params)

    response_level = get_response_level(params)

    params.delete(:responseLevel)
    must_filters = get_must_filters(params)

    s = Tire.search 'leads' do
      query do
        boolean do
          must do
            nested :path => 'people' do
              query do
                filtered do
                  filter :bool, {:must => must_filters}
                end
              end
            end
          end
          must(&response_level) unless response_level.nil?
        end
      end

      size 0
    end

    p s.to_json

    s.results
  end

  def get_leads(params, fields, size, from)

    response_level = get_response_level(params)

    params.delete(:responseLevel)
    must_filters = get_must_filters(params)

    s = Tire.search 'leads' do
      query do
        boolean do
          must do
            nested :path => 'people' do
              query do
                filtered do
                  filter :bool, {:must => must_filters}
                end
              end
            end
          end
          must { range :random_sort, {gte: from} }
          must(&response_level) unless response_level.nil?
        end
      end

      fields fields
      size size
      sort { by :random_sort, 'asc' }
    end

    p s.to_json

    s.results
  end

  def get_response_level(params)
    if params.has_key?(:responseLevel)
      response_level = params[:responseLevel]

      Proc.new {
        range response_level.to_sym, {gte: 1}
      }
    else
      nil
    end

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