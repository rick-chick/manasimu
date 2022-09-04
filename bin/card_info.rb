require_relative '../lib/manasimu.rb'

card_types = Deck.card_types
card_type = card_types.find("MID", 1)

expansions = Expansion.load
p card_type.multiverseid
card_info = scrape_legalities(card_type.multiverseid)
p card_info.legalities

Format.all.each do |format|
  puts "#{format} #{card_info.legalities[format]}"
end
