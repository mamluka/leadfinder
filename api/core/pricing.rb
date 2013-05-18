class Pricing

  def initialize
    @price_addons = {
        0.5 => [:mortgage_purchase_date_ccyymmdd, :mortgage_purchase_price, :most_recent_mortgage_amount, :most_recent_mortgage_date, :most_recent_mortgage_loan_type, :second_most_recent_mortgage_amount, :second_most_recent_mortgage_date, :second_most_recent_mortgage_loan_type, :most_recent_lender, :second_most_recent_lender, :most_recent_lender_name, :second_most_recent_lender_name, :most_recent_mortgage_interest_rate_type, :second_most_recent_mortgage_interest_rate_type, :purchase_1st_mortgage_amount, :purchase_second_mortgage_amount, :purchase_mortgage_date, :purchase_1st_mortgage_loan_type, :purchase_second_mortgage_loan_type, :purchase_lender, :purchase_lender_name, :purchase_1st_mortgage_interest_rate_type, :purchase_second_mortgage_interest_rate_type, :most_recent_mortgage_interest_rate, :second_most_recent_mortgage_interest_rate, :purchase_1st_mortgage_interest_rate, :purchase_second_mortgage_interest_rate, :has_telephone_number]
    }

    @flat_rate = 1.5

  end

  def get_price_for_count(count, filters)
    filters_keys = filters.keys.map { |x| x.to_sym }

    extra_array = @price_addons.keep_if { |price, expensive_field| (filters_keys & expensive_field).any? }.map { |k, v| k }

    if extra_array.any?
      extra = extra_array.inject(:+)
    else
      extra = 0
    end

    @flat_rate + extra
  end
end