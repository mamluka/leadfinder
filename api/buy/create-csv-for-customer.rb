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
    basic_fields = [:first_name, :last_name, :name_prefix, :address, :apartment, :state, :city, :zip, :has_telephone_number, :telephone_number, :do_not_call, :gender, :inferred_household_rank, :exact_age, :income_estimated_household, :net_worth, :number_of_lines_of_credit, :credit_range_of_new_credit, :education, :occupation, :occupation_detailed, :business_owner, :has_children, :number_of_children, :marital_status_in_the_hhld, :home_owner, :length_of_residence, :dwelling_type, :home_market_value, :language, :credit_rating, :pool]

    all_csv_fields = basic_fields | facet_keys_symbols

    suppression_list = SuppressionList.new
    phones_set = suppression_list.get_suppressed_phones order_details['user_id']

    query = Queries.new

    number_of_leads_bought = number_of_leads_bought.to_i
    results = Array.new
    i = 0

    while results.length < number_of_leads_bought
      part_of_results = query.get_leads(facets, 20000, i).map { |x| x.to_hash }.select { |x| !phones_set.include? x[:people].first[:telephone_number] }

      results = results.concat(part_of_results).uniq { |x| x[:household_id] }

      p results.length
      i = i+1
    end

    results = results.take(number_of_leads_bought)


    matched_people = results.map do |r|
      r = r.to_hash
      people = r[:people].select do |x|
        facets.all? do |k, v|
          v = v.to_s.upcase
          k= k.to_sym

          lead_result = x[k]

          if lead_result.nil?
            next false
          end

          if v == 'TRUE' || v == 'FALSE'
            lead_result == (v == 'TRUE' ? true : false)
          elsif v.include?(',')
            v.split(',').any? { |p| p == lead_result }
          elsif v.include?('-')
            minmax = v.split('-').map { |x| x.to_f }
            lead_result >= minmax[0] && lead_result < minmax[1]
          else
            if lead_result.kind_of?(Numeric)
              lead_result == v.to_i
            else
              lead_result == v
            end

          end
        end
      end

      people.first
    end

    file_name = order_details['order_id'] + '.csv'

    translator = FacetsTextTranslator.new

    CSV.open(File.dirname(__FILE__) + '/../../downloads/' + file_name, "wb") do |csv|
      csv << all_csv_fields

      matched_people.each do |x|
        csv << all_csv_fields.map { |facet|
          translator.translate(facet, x[facet])
        }
      end
    end

    require_relative '../../emails/mail_base'
    OrderEmails.download_order(email, order_details['name'], order_details['order_id']).deliver

  end
end