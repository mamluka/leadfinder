class DataConverters
  def initialize
    @dic = {
        income_estimated_household: {
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
            P: 150000,
            Q: 175000,
            R: 250000,
            S: 300000,
        },
        net_worth: {
            A: 0,
            B: 5000,
            C: 10000,
            D: 25000,
            E: 50000,
            F: 100000,
            G: 250000,
            H: 500000,
            I: 1000000,
        },
        credit_rating: {
            A: 1000,
            B: 800,
            C: 750,
            D: 700,
            E: 650,
            F: 600,
            G: 550,
            H: 500,
        },
        home_market_value: {
            A: 0,
            B: 25000,
            C: 50000,
            D: 75000,
            E: 100000,
            F: 125000,
            G: 150000,
            H: 175000,
            I: 200000,
            J: 250000,
            K: 275000,
            L: 300000,
            M: 350000,
            N: 400000,
            O: 450000,
            P: 500000,
            Q: 750000,
            R: 1000000,
            S: 2000000,
        }
    }
  end

  def convert(key, value)
    value.nil? ? nil : @dic[key][value.to_sym]
  end

  def from_yes_no(value)
    !value.nil? && value.downcase == 'y'
  end

  def to_percent(value)
    value.nil? ? nil : value.to_f/10000
  end
end
