require 'backburner'
require 'csv'
require 'securerandom'

require_relative '../core/queries'
require_relative '../core/facets_text_translator'
require_relative 'suppression_list'

class CreateCsvForCustomer
  include Backburner::Queue
  queue "orders"
  queue_priority 0

  def self.perform(email, number_of_leads_bought, facets, order_details)

    facet_keys_symbols = facets.keys.map { |x| x.to_sym }

    facets_to_params = Hash.new
    facets.each { |k, v| facets_to_params[k.to_sym] = v }

    root_fields = [:household_id, :telephone_number, :random_sort]
    people_fields = [:first_name, :last_name, :name_prefix, :address, :apartment, :state, :city, :zip, :has_telephone_number, :do_not_call, :gender, :inferred_household_rank, :exact_age, :income_estimated_household, :net_worth, :number_of_lines_of_credit, :credit_range_of_new_credit, :education, :occupation, :occupation_detailed, :business_owner, :has_children, :number_of_children, :marital_status_in_the_hhld, :home_owner]

    req_people_fields = people_fields.map { |x| 'people.' + x.to_s }.concat(root_fields)
    req_fields = req_people_fields | facet_keys_symbols.map { |x| 'people.' + x.to_s }

    suppression_list = SuppressionList.new
    phones_set = suppression_list.get_suppressed_phones order_details['user_id']

    query = Queries.new

    number_of_leads_bought = number_of_leads_bought.to_i
    results = Array.new
    chunk_size = number_of_leads_bought > 5000 ? 5000 : number_of_leads_bought

    total_leads_available = query.count_leads(facets_to_params).total

    p total_leads_available

    cycle_count = 0
    cycle_limit = total_leads_available/chunk_size

    random_seed = Random.rand(99999999)
    used_random_seed = 0

    while results.length < number_of_leads_bought

      p 'Start query'
      start_time = Time.now
      if phones_set.length == 0
        #next if random_history.any? { |x| random_seed >= x[0] && random_seed <= x[1] }
        leads = query.get_leads(facets_to_params, req_fields, chunk_size, cycle_count*chunk_size, random_seed, used_random_seed)
        if leads.length == 0
          used_random_seed = random_seed
          random_seed = 0
          cycle_count = 0
          p 'Starting from 0'
          next
        end
      else
        break if cycle_count > cycle_limit
        leads = query.get_leads_sequential(facets_to_params, req_fields, chunk_size, cycle_count*chunk_size)
      end

      p "Fetch took #{Time.now-start_time} secs"

      p 'End Query'

      cycle_count = cycle_count + 1

      p 'Start Mapping'

      part_of_results = leads
      .select { |x|
        !phones_set.include?(x.telephone_number)
      }
      .map { |x|
        x.people.map { |x|
          x.to_hash.select { |k, v| !v.nil? }
        }
      }

      p 'End mapping'

      next if part_of_results.length == 0

      results = results.concat(part_of_results).uniq { |x| x.first[:household_id] }

      p results.length
    end

    matched_people = results.map do |r|
      people = r.select do |x|
        facets_to_params
        .select { |x| x!= :responseLevel }
        .all? do |k, v|
          v = v.to_s.upcase

          lead_result = x[k]

          if lead_result.nil?
            result = false
          else
            if v == 'TRUE' || v == 'FALSE'
              result = lead_result == (v == 'TRUE' ? true : false)
            elsif v.include?(',')
              result = v.split(',').any? { |p| p == lead_result }
            elsif v.include?('-')
              minmax = v.split('-').map { |x| x.to_f }
              result = lead_result >= minmax[0] && lead_result < minmax[1]
            else
              if lead_result.kind_of?(Numeric)
                result = lead_result == v.to_i
              else
                result = lead_result == v

              end
            end
          end

          result
        end
      end

      people.first
    end

    file_name = order_details['order_id'] + '.csv'

    translator = FacetsTextTranslator.new

    csv_fields = [:telephone_number] | people_fields

    CSV.open(File.dirname(__FILE__) + '/../../downloads/' + file_name, 'wb') do |csv|
      csv << csv_fields

      matched_people.each do |x|
        csv << csv_fields.map { |facet|
          translator.translate(facet, x[facet])
        }
      end
    end

    require_relative '../../emails/mail_base'

    p 'Sending email'

    OrderEmails.download_order(email, order_details['name'], order_details['order_id']).deliver

    matched_people.clear
    results.clear

  end
end