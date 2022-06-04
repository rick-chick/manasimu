require_relative '../lib/manasimu.rb'
require_relative 'api_util.rb'


prev = File.open(File.expand_path( '../../db/expansions', __FILE__ ), "r") do |file|
  Marshal.load(file)
end

crnt = []
get_sets.each do |code, name|
  set = Expansion.new
  set.code = code
  set.name = name
  set.exists = false
  crnt << set
end

card_types = Deck.card_types

crnt.each do |set|

  # check exists
  exists = prev.find do |prev_set|
    prev_set.code == set.code and prev_set.exists
  end
  next if exists

  # request to api to get card names
  get_names(set.code).each do |set_code, number, names|
    card_type = card_types.find(set_code, number.to_i)
    if (card_type)
      card_type.contents[0].names = names
    end
  end

  set.exists = true

  # update 
  File.open(File.expand_path( '../../db/card_type_aggregate', __FILE__ ), "w") do |file|
    file.write(Marshal.dump(card_types))
  end

  # update 
  File.open(File.expand_path( '../../db/expansions', __FILE__ ), "w") do |file|
    file.write(Marshal.dump(crnt))
  end
end
