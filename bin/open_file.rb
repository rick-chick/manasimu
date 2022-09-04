require_relative "../lib/manasimu.rb"

card_types = File.open(File.expand_path( '../../db/card_type_aggregate', __FILE__ ), "r") do |file|
  Marshal.load(file)
end

debugger
