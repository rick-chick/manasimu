require_relative "../lib/manasimu.rb"
require_relative "./db_util.rb"

card_types = all_card_details

File.open(File.expand_path( '../../db/card_type_aggregate', __FILE__ ), "w") do |file|
  file.write(Marshal.dump(card_types))
end

