require 'csv'

tab_file = ARGV[0]
csv_file = ARGV[1]

converted_csv = Array.new

CSV.foreach(tab_file, {:col_sep => "\t"}) { |csv|
  converted_csv << csv
}

CSV.open(csv_file, 'wb') do |csv|
  converted_csv.each { |x| csv << x }
end
