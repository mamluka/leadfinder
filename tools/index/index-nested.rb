require 'tire'
require 'csv'
require 'time'
require 'securerandom'
require 'logger'
require 'digest/md5'

require_relative 'datafile-converters'

class IndexLeads
  def initialize
    @logger = Logger.new('logfile.log')
    @leads_logger = Logger.new('leadsops.log')
    @lines_logger = Logger.new('lines.log')
  end

  def index(file, chunk, sep)

    Tire.index 'leads' do
      create settings: {
          number_of_shards: 1,
          number_of_replicas: 0,
          refresh_interval: -1,
          'translog.flush_threshold_ops' => 50000,
          'translog.flush_threshold_size' => '2000mb',
          'translog.flush_threshold_period' => '210m',
          'merge.policy.max_merge_at_once' => 20,
          'merge.policy.segments_per_tier' => 40,
          'merge.policy.max_merged_segment' => '2g',
      }
    end

    Tire::Configuration.client.put Tire.index('leads').url+'/household/_mapping',
                                   {:household => {:properties => {:people => {:type => 'nested'}}}}.to_json

    converter = DataConverters.new

    leads = Array.new

    counter = 0
    total_counter = 0

    start_time = Time.now
    total_time = Time.now

    timer = Time.now
    CSV.foreach(file, {:headers => true, :header_converters => :symbol, :col_sep => sep}) { |csv|

      total_counter = total_counter + 1
      next if csv.header_row?

      lead = extract_lead(converter, csv)

      if leads.length == 0
        leads << lead
        counter = counter + 1
        next
      end

      leads << lead

      if leads.length > chunk && leads[leads.length-2][:household_id] != leads.last[:household_id]

        end_timer = Time.now

        people = leads
        .take(leads.length-1)
        .group_by { |x| x[:household_id] }
        .map { |k, v|
          unique_leads = v.uniq { |x| x[:first_name] + x[:last_name] }
          {
              _id: k,
              telephone_number: unique_leads[0][:telephone_number],
              type: 'household',
              household_id: k,
              household_size: v.length,
              people: unique_leads
          }
        }

        Tire.index 'leads' do
          import people
        end

        batch_time = Time.now-start_time
        @logger.info "Possessed #{people.length}, this batch took #{batch_time} seconds [#{people.length/batch_time} docs/sec], the csv read took #{end_timer-timer}"
        start_time = Time.now
        @logger.info "Total time passed is #{Time.now-total_time} seconds, we processed #{total_counter}"
        last = leads.last
        leads.clear
        leads << last

        timer = Time.now
      end

    }
  end

  def diff(first, second)
    out = {}

    first.each do |k, v|
      unless v == second[k]
        out[k] = [v, second[k]]
      end
    end

    out
  end

  def merge_leads(first, second)
    first.each do |k, v|
      second_value = second[k]

      next if second_value == v

      if v.kind_of?(Array)
        first[k] << second_value
      else
        first[k] = [v, second_value]
      end
    end

    first
  end

  def extract_lead(convert, csv)
    full_address = "#{csv[:st]}:#{csv[:city]}:#{csv[:addr]}:#{csv[:zip]}:#{csv[:apt]}"
    household_id = csv[:phone].nil? ? Digest::MD5.hexdigest(full_address) : Digest::MD5.hexdigest(csv[:phone])

    {
        random_sort: Random.rand(150000000),
        household_id: household_id,
        first_name: csv[:fn],
        last_name: csv[:ln],
        name_prefix: csv[:name_pre],
        address: csv[:addr],
        apartment: csv[:apt],
        state: csv[:st],
        city: csv[:city],
        zip: csv[:zip],
        full_address: full_address,
        has_telephone_number: !csv[:phone].nil?,
        telephone_number: csv[:phone].nil? ? '0000000000' : csv[:phone],
        do_not_call: convert.from_yes_no(csv[:do_not_call]),
        gender: csv[:gender],
        inferred_household_rank: csv[:inf_hh_rank].to_i,
        exact_age: csv[:exact_age].to_i,
        income_estimated_household: convert.convert(:income_estimated_household, csv[:hh_income]),
        net_worth: convert.convert(:net_worth, csv[:net_worth]),
        number_of_lines_of_credit: csv[:credit_lines].to_i,
        credit_range_of_new_credit: csv[:credit_range_new].to_i,
        education: csv[:educ],
        occupation: csv[:occ_occup],
        occupation_detailed: csv[:occ_occup_det],
        business_owner: csv[:occ_busn_ownr],
        has_children: (csv[:num_kids].to_i > 0),
        number_of_children: csv[:num_kids].to_i,
        marital_status_in_the_hhld: csv[:hh_marital_stat],
        home_owner: csv[:home_ownr],
        length_of_residence: csv[:lor].to_i,
        dwelling_type: csv[:dwell_typ],
        home_market_value: convert.convert(:home_market_value, csv[:home_mkt_value]),
        language: csv[:ethnic_lang],
        credit_rating: convert.convert(:credit_rating, csv[:credit_rating]),
        pool: convert.from_yes_no(csv[:prop_pool]),
        year_built: csv[:prop_bld_yr].to_i,
        air_conditioning: csv[:prop_ac],
        mortgage_purchase_date_ccyymmdd: (Time.parse(csv[:genl_purch_dt]).year rescue nil),
        loan_to_value: csv[:genl_loan_to_value].nil? ? nil : csv[:genl_loan_to_value].to_f/100,
        mortgage_purchase_price: csv[:genl_purch_amt].to_i,
        most_recent_mortgage_amount: csv[:mr_amt].to_i,
        most_recent_mortgage_date: (Time.parse(csv[:mr_dt]).year rescue nil),
        most_recent_mortgage_loan_type: csv[:mr_loan_typ],
        second_most_recent_mortgage_amount: csv[:mr2_amt].to_i,
        second_most_recent_mortgage_date: (Time.parse(csv[:mr2_dt]).year rescue nil),
        second_most_recent_mortgage_loan_type: csv[:mr2_loan_typ],
        most_recent_lender: csv[:mr_lendr_cd],
        second_most_recent_lender: csv[:mr2_lendr_cd],
        most_recent_lender_name: csv[:mr_lendr],
        second_most_recent_lender_name: csv[:mr2_lendr],
        most_recent_mortgage_interest_rate_type: csv[:mr_rate_typ],
        second_most_recent_mortgage_interest_rate_type: csv[:mr2_rate_typ],
        purchase_1st_mortgage_amount: csv[:p1_amt].to_i,
        purchase_second_mortgage_amount: csv[:p2_amt].to_i,
        purchase_mortgage_date: (Time.parse(csv[:p1_dt]).year rescue nil),
        purchase_1st_mortgage_loan_type: csv[:p1_loan_typ],
        purchase_second_mortgage_loan_type: csv[:p2_loan_typ],
        purchase_lender: csv[:p1_lendr_cd],
        purchase_lender_name: csv[:p1_lendr],
        purchase_1st_mortgage_interest_rate_type: csv[:p1_rate_typ],
        purchase_second_mortgage_interest_rate_type: csv[:p2_rate_typ],
        most_recent_mortgage_interest_rate: convert.to_percent(csv[:mr_rate]),
        second_most_recent_mortgage_interest_rate: convert.to_percent(csv[:mr2_rate]),
        purchase_1st_mortgage_interest_rate: convert.to_percent(csv[:p1_rate]),
        purchase_second_mortgage_interest_rate: convert.to_percent(csv[:p2_rate]),
        investing_active: convert.from_yes_no(csv[:invest_act]),
        investments_personal: convert.from_yes_no(csv[:invest_pers]),
        investments_real_estate: convert.from_yes_no(csv[:invest_rl_est]),
        investments_stocks_bonds: convert.from_yes_no(csv[:invest_stocks]),
        reading_financial_newsletter_subscribers: convert.from_yes_no(csv[:invest_read_fin_news]),
        money_seekers: convert.from_yes_no(csv[:invest_money_seekr]),
        investing_finance_grouping: convert.from_yes_no(csv[:int_grp_invest]),
        investments_foreign: convert.from_yes_no(csv[:invest_foreign]),
        investment_estimated_residential_properties_owned: convert.from_yes_no(csv[:invest_est_prop_own]),
        american_express_gold_premium: convert.from_yes_no(csv[:cc_amex_prem]),
        american_express_regular: convert.from_yes_no(csv[:cc_amex_reg]),
        discover_gold_premium: convert.from_yes_no(csv[:cc_disc_prem]),
        discover_regular: convert.from_yes_no(csv[:cc_disc_reg]),
        gasoline_or_retail_card_gold_premium: convert.from_yes_no(csv[:cc_gas_prem]),
        gasoline_or_retail_card_regular: convert.from_yes_no(csv[:cc_gas_reg]),
        mastercard_gold_premium: convert.from_yes_no(csv[:cc_mc_prem]),
        mastercard_regular: convert.from_yes_no(csv[:cc_mc_reg]),
        visa_gold_premium: convert.from_yes_no(csv[:cc_visa_prem]),
        visa_regular: convert.from_yes_no(csv[:cc_visa_reg]),
        bank_card_holder: convert.from_yes_no(csv[:cc_hldr_bank]),
        gas_department_retail_card_holder: convert.from_yes_no(csv[:cc_hldr_gas]),
        travel_and_entertainment_card_holder: convert.from_yes_no(csv[:cc_hldr_te]),
        credit_card_holder_unknown_type: convert.from_yes_no(csv[:cc_hldr_unk]),
        premium_card_holder: convert.from_yes_no(csv[:cc_hldr_prem]),
        upscale_department_store_card_holder: convert.from_yes_no(csv[:cc_hldr_ups_dept]),
        credit_card_user: convert.from_yes_no(csv[:cc_user]),
        credit_card_new_issue: convert.from_yes_no(csv[:cc_new_issue]),
        bank_card_presence_in_household: convert.from_yes_no(csv[:cc_bank_cd_in_hh]),
        mail_order_buyer: convert.from_yes_no(csv[:buy_mo_buyer]),
        mail_order_responder: convert.from_yes_no(csv[:buy_mo_respdr]),
        online_purchasing_indicator: convert.from_yes_no(csv[:buy_ol_purch_ind]),
        membership_clubs: convert.from_yes_no(csv[:buy_mem_clubs]),
        value_priced_general_merchandise: convert.from_yes_no(csv[:buy_value_priced]),
        apparel_womens: convert.from_yes_no(csv[:buy_wmns_apparel]),
        apparel_womens_petite: convert.from_yes_no(csv[:buy_wmns_petite_apparel]),
        apparel_womens_plus_sizes: convert.from_yes_no(csv[:buy_wmns_plus_apparel]),
        young_womens_apparel: convert.from_yes_no(csv[:buy_young_wmns_apparel]),
        apparel_mens: convert.from_yes_no(csv[:buy_mns_apparel]),
        apparel_mens_big_and_tall: convert.from_yes_no(csv[:buy_mns_big_apparel]),
        young_mens_apparel: convert.from_yes_no(csv[:buy_young_mns_apparel]),
        apparel_hildrens: convert.from_yes_no(csv[:buy_kids_apparel]),
        health_and_beauty: convert.from_yes_no(csv[:buy_health_beauty]),
        beauty_cosmetics: convert.from_yes_no(csv[:buy_cosmetics]),
        jewelry: convert.from_yes_no(csv[:buy_jewelry]),
        #donation_contribution: convert.from_yes_no(csv[:int_grp_donor]),
        #mail_order_donor: convert.from_yes_no(csv[:donr_mail_ord]),
        #charitable_donation: convert.from_yes_no(csv[:donr_charitable]),
        #animal_welfare_charitable_donation: convert.from_yes_no(csv[:donr_animal]),
        #arts_or_cultural_charitable_donation: convert.from_yes_no(csv[:donr_arts]),
        #childrens_charitable_donation: convert.from_yes_no(csv[:donr_kids]),
        #environment_or_wildlife_charitable_donation: convert.from_yes_no(csv[:donr_wildlife]),
        #environmental_issues_charitable_donation: convert.from_yes_no(csv[:donr_environ]),
        #health_charitable_donation: convert.from_yes_no(csv[:donr_health]),
        #international_aid_charitable_donation: convert.from_yes_no(csv[:donr_intl_aid]),
        #political_charitable_donation: convert.from_yes_no(csv[:donr_pol]),
        #political_conservative_charitable_donation: convert.from_yes_no(csv[:donr_pol_cons]),
        #political_liberal_charitable_donation: convert.from_yes_no(csv[:donr_pol_lib]),
        #religious_charitable_donation: convert.from_yes_no(csv[:donr_relig]),
        #veterans_charitable_donation: convert.from_yes_no(csv[:donr_vets]),
        #other_types_of_charitable_donations: convert.from_yes_no(csv[:donr_oth]),
        #community_charities: convert.from_yes_no(csv[:donr_comm_char]),

    }
  end

end

index = IndexLeads.new
chunk = ARGV[1].nil? ? 3500 : ARGV[1].to_i
sep = ARGV[2].nil? ? ',' : ARGV[2]

index.index ARGV[0], chunk, sep



