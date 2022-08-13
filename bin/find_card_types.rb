require_relative '../lib/manasimu.rb'

lines = File.open('test_ja.txt', 'r') do |file|
  file.readlines
end

Deck.find_card_types(lines).each do |type|
  puts "#{type.name} #{type.set_code} #{type.number} #{type.names[0]}"
end
