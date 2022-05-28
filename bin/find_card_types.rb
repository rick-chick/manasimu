require_relative '../lib/manasimu.rb'

lines = File.open('test.txt', 'r') do |file|
  file.readlines
end

puts Deck.find_card_types(lines)
