require 'backburner'
require 'csv'
require 'securerandom'

require_relative '../core/queries'
require_relative '../core/facets_text_translator'

class CreateCsvForCustomer
  include Backburner::Queue
  queue "orders"
  queue_priority 0

  def self.perform(email, number_of_leads_bought, facets, order_details)

    facet_keys_symbols = facets.keys.map { |x| x.to_sym }
    basic_fields = [:first_name, :last_name, :name_prefix, :address, :apartment, :state, :city, :zip, :has_telephone_number, :telephone_number, :do_not_call, :gender, :inferred_household_rank, :exact_age, :income_estimated_household, :net_worth, :number_of_lines_of_credit, :credit_range_of_new_credit, :education, :occupation, :occupation_detailed, :business_owner, :has_children, :number_of_children, :marital_status_in_the_hhld, :home_owner, :length_of_residence, :dwelling_type, :home_market_value, :language, :credit_rating, :pool]

    all_csv_fields = basic_fields | facet_keys_symbols


    query = Queries.new
    results = query.get_leads facets, number_of_leads_bought.to_i


    matched_people = results.map do |r|
      r = r.to_hash
      people = r[:people].select do |x|
        facets.all? do |k, v|
          v = v.upcase

          if x[k].nil?
            next false
          end

          if v == 'TRUE' || v == 'FALSE'
            x[k] == (v == 'TRUE' ? true : false)
          elsif v.include?(',')
            v.split(',').any? { |p| p == x[k] }
          elsif v.include?('-')
            minmax = v.split('-').map { |x| x.to_f }
            x[k] >= minmax[0] && x[k] < minmax[1]
          else
            x[k] == v
          end
        end
      end

      people.first
    end

    file_name = order_details[:order_id] + '.csv'

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
    OrderEmails.download_order(email, order_details[:name], order_details[:order_id]).deliver

  end
end