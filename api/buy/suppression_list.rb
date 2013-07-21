require 'set'

class SuppressionList
  def get_suppressed_phones(user_id)

    dir_name = File.dirname(__FILE__) + '/../../users/' + user_id

    files = Dir.glob(dir_name+'/*')

    phones = Array.new

    files.each do |f|
      File.open(f, 'r').each do |line|
        phones_per_line = line.scan(/\d{10}/)
        unless phones_per_line.length == 0
          phones << phones_per_line
        end
        next
      end
    end

    Set.new(phones)
  end
end