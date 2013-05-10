require 'tire'
require 'csv'
require 'time'
require 'securerandom'
require 'logger'

require_relative 'datafile-converters'

class IndexLeads
  def initialize
    @logger = Logger.new('logfile.log')
  end

  def index(file)

    convert = DataConverters.new

    leads = Array.new

    counter = 0

    start_time = Time.now
    total_time = Time.now
    CSV.foreach(file, {:headers => true, :header_converters => :symbol}) { |csv|
      leads << {
          first_name: csv[:fn],
          last_name: csv[:ln],
          name_prefix: csv[:name_pre],
          address: csv[:addr],
          apartment: csv[:apt],
          state: csv[:st],
          city: csv[:city],
          zip: csv[:zip],
          has_telephone_number: !csv[:phone].nil?,
          telephone_number: csv[:phone],
          do_not_call: csv[:do_not_call],
          gender: csv[:gender],
          inferred_household_rank: csv[:inf_hh_rank],
          exact_age: csv[:exact_age].to_i,
          income_estimated_household: convert.convert(:income_estimated_household, csv[:hh_income]),
          net_worth: convert.convert(:net_worth, csv[:net_worth]),
          number_of_lines_of_credit: csv[:credit_lines],
          credit_range_of_new_credit: csv[:credit_range_new],
          education: csv[:educ],
          occupation: csv[:occ_occup],
          occupation_detailed: csv[:occ_occup_det],
          business_owner: csv[:occ_busn_ownr],
          number_of_children: csv[:num_kids],
          marital_status_in_the_hhld: csv[:hh_marital_stat],
          home_owner: csv[:home_ownr],
          length_of_residence: csv[:lor],
          dwelling_type: csv[:dwell_typ],
          home_market_value: convert.convert(:home_market_value, csv[:home_mkt_value]),
          language: csv[:ethnic_lang],
          credit_rating: convert.convert(:credit_rating, csv[:credit_rating]),
          pool: csv[:prop_pool],
          mortgage_purchase_date_ccyymmdd: (Time.parse(csv[:genl_purch_dt]).to_i rescue nil),
          mortgage_purchase_price: csv[:genl_purch_amt],
          most_recent_mortgage_amount: csv[:mr_amt],
          most_recent_mortgage_date: (Time.parse(csv[:mr_dt]).to_i rescue nil),
          most_recent_mortgage_loan_type: csv[:mr_loan_typ],
          second_most_recent_mortgage_amount: csv[:mr2_amt],
          second_most_recent_mortgage_date: (Time.parse(csv[:mr2_dt]).to_i rescue nil),
          second_most_recent_mortgage_loan_type: csv[:mr2_loan_typ],
          most_recent_lender: csv[:mr_lendr_cd],
          second_most_recent_lender: csv[:mr2_lendr_cd],
          most_recent_lender_name: csv[:mr_lendr],
          second_most_recent_lender_name: csv[:mr2_lendr],
          most_recent_mortgage_interest_rate_type: csv[:mr_rate_typ],
          second_most_recent_mortgage_interest_rate_type: csv[:mr2_rate_typ],
          purchase_1st_mortgage_amount: csv[:p1_amt],
          purchase_second_mortgage_amount: csv[:p2_amt],
          purchase_mortgage_date: (Time.parse(csv[:p1_dt]).to_i rescue nil),
          purchase_1st_mortgage_loan_type: csv[:p1_loan_typ],
          purchase_second_mortgage_loan_type: csv[:p2_loan_typ],
          purchase_lender: csv[:p1_lendr_cd],
          purchase_lender_name: csv[:p1_lendr],
          purchase_1st_mortgage_interest_rate_type: csv[:p1_rate_typ],
          purchase_second_mortgage_interest_rate_type: csv[:p2_rate_typ],
          most_recent_mortgage_interest_rate: csv[:mr_rate],
          second_most_recent_mortgage_interest_rate: csv[:mr2_rate],
          purchase_1st_mortgage_interest_rate: csv[:p1_rate],
          purchase_second_mortgage_interest_rate: csv[:p2_rate],
          investing_active: csv[:invest_act],
          investments_personal: csv[:invest_pers],
          investments_real_estate: csv[:invest_rl_est],
          investments_stocks_bonds: csv[:invest_stocks],
          reading_financial_newsletter_subscribers: csv[:invest_read_fin_news],
          money_seekers: csv[:invest_money_seekr],
          investing_finance_grouping: csv[:int_grp_invest],
          investments_foreign: csv[:invest_foreign],
          investment_estimated_residential_properties_owned: csv[:invest_est_prop_own],
          american_express_gold_premium: csv[:cc_amex_prem],
          american_express_regular: csv[:cc_amex_reg],
          discover_gold_premium: csv[:cc_disc_prem],
          discover_regular: csv[:cc_disc_reg],
          gasoline_or_retail_card_gold_premium: csv[:cc_gas_prem],
          gasoline_or_retail_card_regular: csv[:cc_gas_reg],
          mastercard_gold_premium: csv[:cc_mc_prem],
          mastercard_regular: csv[:cc_mc_reg],
          visa_gold_premium: csv[:cc_visa_prem],
          visa_regular: csv[:cc_visa_reg],
          bank_card_holder: csv[:cc_hldr_bank],
          gas_department_retail_card_holder: csv[:cc_hldr_gas],
          travel_and_entertainment_card_holder: csv[:cc_hldr_te],
          credit_card_holder_unknown_type: csv[:cc_hldr_unk],
          premium_card_holder: csv[:cc_hldr_prem],
          upscale_department_store_card_holder: csv[:cc_hldr_ups_dept],
          credit_card_user: csv[:cc_user],
          credit_card_new_issue: csv[:cc_new_issue],
          bank_card_presence_in_household: csv[:cc_bank_cd_in_hh],
          mail_order_buyer: csv[:buy_mo_buyer],
          mail_order_responder: csv[:buy_mo_respdr],
          online_purchasing_indicator: csv[:buy_ol_purch_ind],
          membership_clubs: csv[:buy_mem_clubs],
          value_priced_general_merchandise: csv[:buy_value_priced],
          apparel_womens: csv[:buy_wmns_apparel],
          apparel_womens_petite: csv[:buy_wmns_petite_apparel],
          apparel_womens_plus_sizes: csv[:buy_wmns_plus_apparel],
          young_womens_apparel: csv[:buy_young_wmns_apparel],
          apparel_mens: csv[:buy_mns_apparel],
          apparel_mens_big_and_tall: csv[:buy_mns_big_apparel],
          young_mens_apparel: csv[:buy_young_mns_apparel],
          apparel_hildrens: csv[:buy_kids_apparel],
          health_and_beauty: csv[:buy_health_beauty],
          beauty_cosmetics: csv[:buy_cosmetics],
          jewelry: csv[:buy_jewelry],
          donation_contribution: csv[:int_grp_donor],
          mail_order_donor: csv[:donr_mail_ord],
          charitable_donation: csv[:donr_charitable],
          animal_welfare_charitable_donation: csv[:donr_animal],
          arts_or_cultural_charitable_donation: csv[:donr_arts],
          childrens_charitable_donation: csv[:donr_kids],
          environment_or_wildlife_charitable_donation: csv[:donr_wildlife],
          environmental_issues_charitable_donation: csv[:donr_environ],
          health_charitable_donation: csv[:donr_health],
          health_charitable_donation: csv[:donr_health],
          international_aid_charitable_donation: csv[:donr_intl_aid],
          political_charitable_donation: csv[:donr_pol],
          political_conservative_charitable_donation: csv[:donr_pol_cons],
          political_liberal_charitable_donation: csv[:donr_pol_lib],
          religious_charitable_donation: csv[:donr_relig],
          veterans_charitable_donation: csv[:donr_vets],
          other_types_of_charitable_donations: csv[:donr_oth],
          community_charities: csv[:donr_comm_char],
      } if not csv.header_row?

      counter =counter + 1

      if leads.length % 2000 == 0
        Tire.index 'leads' do
          import leads
        end

        @logger.info "Possessed #{counter}, this batch took #{Time.now-start_time} seconds"
        start_time = Time.now
        @logger.info "Total time passed is #{Time.now-total_time} seconds"
        leads.clear
      end


    }

    @logger.info "Possessed #{counter}"

    Tire.index 'leads' do
      import leads
    end

    Tire.index 'leads' do
      refresh
    end
  end
end

index = IndexLeads.new
index.index ARGV[0]



