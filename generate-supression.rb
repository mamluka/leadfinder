File.open('suppression.txt', 'w') do |f|
  (1..25000000).each {
    f.write "0000000000\n"
  }
end