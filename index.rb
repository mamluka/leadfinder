require 'tire'
require 'csv'
require 'time'
require 'securerandom'
require 'logger'

income = {
    A: 0,
    B: 10000,
    C: 15000,
    D: 20000,
    E: 25000,
    F: 30000,
    G: 35000,
    H: 40000,
    I: 45000,
    J: 50000,
    K: 55000,
    L: 60000,
    M: 65000,
    N: 70000,
    O: 100000,
    P: 15000,
    Q: 175000,
    O: 200000,
    R: 250000,
    S: 300000,
}

net_worth = {
    A: 0,
    B: 5000,
    C: 10000,
    D: 25000,
    E: 50000,
    F: 100000,
    G: 250000,
    H: 500000,
    I: 1000000,
}

credit_rating = {
    A: 1000,
    B: 800,
    C: 750,
    D: 700,
    E: 650,
    F: 600,
    G: 550,
    H: 500,
}

logger = Logger.new('logfile.log')

csv_file = ARGV[0]

leads = Array.new

counter = 0
start_time = Time.now
total_time = Time.now
CSV.foreach(csv_file, {:headers => true, :header_converters => :symbol}) { |csv|

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
      time_zone: csv[:time_zn],
      gender: csv[:gender],
      inferred_household_rank: csv[:inf_hh_rank],
      exact_age: csv[:exact_age].to_i,
      most_recent_mortgage_amount: csv[:mr_amt],
      most_recent_mortgage_date: csv[:mr_dt],
      most_recent_mortgage_loan_type: csv[:mr_loan_typ],
      second_most_recent_mortgage_amount: csv[:mr2_amt],
      second_most_recent_mortgage_date: csv[:mr2_dt],
      second_most_recent_mortgage_loan_type: csv[:mr2_loan_typ],
      most_recent_lender: csv[:mr_lendr_cd],
      second_most_recent_lender: csv[:mr2_lendr_cd],
      most_recent_lender_name: csv[:mr_lendr],
      second_most_recent_lender_name: csv[:mr2_lendr],
      most_recent_mortgage_interest_rate_type: csv[:mr_rate_typ],
      second_most_recent_mortgage_interest_rate_type: csv[:mr2_rate_typ],
      loan_to_value: csv[:genl_loan_to_value],
      purchase_price: csv[:genl_purch_amt],
      air_conditioning: csv[:prop_ac],
      pool: csv[:prop_pool],
      home_owner: csv[:home_ownr],
      length_of_residence: csv[:lor],
      dwelling_type: csv[:dwell_typ],
      bank_card_holder: csv[:cc_hldr_bank],
      credit_card_user: csv[:cc_user],
      bank_card_presence_in_household: csv[:cc_bank_cd_in_hh],
      income_estimated_household: csv[:hh_income].nil? ? nil : income[csv[:hh_income].to_sym],
      net_worth: csv[:net_worth].nil? ? nil : net_worth[csv[:net_worth].to_sym],
      credit_rating: csv[:credit_rating].nil? ? nil : credit_rating[csv[:credit_rating].to_sym],
      ethnic: csv[:ethnic],
      language: csv[:ethnic_lang],
      presence_of_children: csv[:pres_kids],
      education: csv[:educ],
      purchase_date_ccyymmdd: csv[:genl_purch_dt],
      sales_transaction: csv[:genl_sls_trans],
      purchase_1st_mortgage_amount: csv[:p1_amt],
      purchase_second_mortgage_amount: csv[:p2_amt],
      purchase_mortgage_date: csv[:p1_dt],
      purchase_1st_mortgage_loan_type: csv[:p1_loan_typ],
      purchase_second_mortgage_loan_type: csv[:p2_loan_typ],
      purchase_lender: csv[:p1_lendr_cd],
      purchase_lender_name: csv[:p1_lendr],
      purchase_1st_mortgage_interest_rate_type: csv[:p1_rate_typ],
      purchase_second_mortgage_interest_rate_type: csv[:p2_rate_typ],
      most_recent_mortgage_interest_rate_note_inferred_decimal_nndddd: csv[:mr_rate],
      second_most_recent_mortgage_interest_rate_note_inferred_decimal_nndddd: csv[:mr2_rate],
      purchase_1st_mortgage_interest_rate_note_inferred_decimal_nndddd: csv[:p1_rate],
      purchase_second_mortgage_interest_rate_note_inferred_decimal_nndddd: csv[:p2_rate],
      year_built: csv[:prop_bld_yr],
      zip4: csv[:zip4],
      delivery_point_bar: csv[:dpc],
      carrier_route: csv[:car_rte],
      walk_sequence: csv[:walk_seq],
      lot_carrier_line_of_travel: csv[:lot],
      fips_state: csv[:fips_st],
      fips_country: csv[:fips_cty],
      latitude: csv[:latitude],
      longitude: csv[:longitude],
      address_type: csv[:addr_typ],
      msa: csv[:msa],
      cbsa: csv[:cbsa],
      address_line: csv[:addr_line],
      dma: csv[:dma_suppr],
      geo_match_level: csv[:geo_match],
      census_tract: csv[:cens_track],
      census_block_group: csv[:cens_blk_grp],
      census_block: csv[:cens_blk],
      dsf_deliverability: csv[:dsf_ind],
      delivery_point_drop: csv[:dpd_ind],
      occupation: csv[:occ_occup],
      occupation_detailed: csv[:occ_occup_det],
      business_owner: csv[:occ_busn_ownr],
      number_of_children: csv[:num_kids],
      number_of_lines_of_credit_trade_counter: csv[:credit_lines],
      credit_range_of_new_credit: csv[:credit_range_new],
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
      luggage: csv[:buy_luggage],
      travel_domestic: csv[:int_trav_us],
      travel_international: csv[:int_trav_intl],
      travel_cruise_vacations: csv[:int_trav_cruise],
      home_living: csv[:life_home],
      diy_living: csv[:life_diy],
      sporty_living: csv[:life_sporty],
      upscale_living: csv[:life_upscale],
      cultural_artistic_living: csv[:life_culture],
      highbrow: csv[:life_highbrow],
      high_tech_living: csv[:life_ht],
      common_living: csv[:life_common],
      professional_living: csv[:life_prof],
      broader_living: csv[:life_broader],
      exercise_health_grouping: csv[:int_grp_exer],
      exercise_running_jogging: csv[:int_fit_jog],
      exercise_walking: csv[:int_fit_walk],
      exercise_aerobic: csv[:int_fit_aerob],
      spectator_sports_auto_motorcycle_racing: csv[:int_sport_spect_auto],
      spectator_sports_tv_sports: csv[:int_sport_spect_tv_sports],
      spectator_sports_football: csv[:int_sport_spect_foot],
      spectator_sports_baseball: csv[:int_sport_spect_base],
      spectator_sports_basketball: csv[:int_sport_spect_bskt],
      spectator_sports_hockey: csv[:int_sport_spect_hockey],
      spectator_sports_soccer: csv[:int_sport_spect_soccer],
      tennis: csv[:int_sport_tennis],
      golf: csv[:int_sport_golf],
      snow_skiing: csv[:int_sport_snow_ski],
      motorcycling: csv[:int_sport_mtrcycl],
      nascar: csv[:int_sport_nascar],
      boating_sailing: csv[:int_sport_boating],
      scuba_diving: csv[:int_sport_scuba],
      sports_and_leisure: csv[:buy_sport_leis],
      hunting: csv[:buy_hunting],
      fishing: csv[:int_sport_fishing],
      camping_hiking: csv[:int_sport_camp],
      hunting_shooting: csv[:int_sport_shoot],
      sports_grouping: csv[:int_grp_sports],
      outdoors_grouping: csv[:int_grp_outdoor],
      health_medical: csv[:int_fit_health_med],
      dieting_weight_loss: csv[:int_fit_diet],
      self_improvement: csv[:int_fit_self_imp],
      automotive_auto_parts_and_accessories: csv[:buy_auto_parts],
      pass_prospector_value: csv[:genl_pp_home_value],
      sweepstakes_contests: csv[:int_hob_sweeps],
      travel_grouping: csv[:int_grp_travel],
      travel: csv[:int_trav_genl],
  } if not csv.header_row?

  counter =counter + 1

  if leads.length % 2000 == 0
    Tire.index 'leads' do
      import leads
    end

    logger.info "Possessed #{counter}, this batch took #{Time.now-start_time} seconds"
    start_time = Time.now
    logger.info "Total time passed is #{Time.now-total_time} seconds"
    leads.clear
  end


}

logger.info "Possessed #{counter}"

Tire.index 'leads' do
  import leads
end

Tire.index 'leads' do
  refresh
end



