require_relative '../lib/manasimu.rb'

set_code = nil

prev = Expansion.load
card_types = CardTypeAggregate.new
notfounds = []
# card_types = Deck.card_types
# card_types.sort!

sets = get_sets

crnt = []
if set_code
  inf = sets.find do |set| set[0] == set_code end
  exit if not inf
  set = Expansion.new
  set.code = set_code
  set.name = inf[1]
  set.exists = false
  crnt << set
else
  sets.each do |code, name|
    set = Expansion.new
    set.code = code
    set.name = name
    set.exists = false
    crnt << set
  end
end


crnt.each do |set|

  # check exists
  exists = prev.find do |prev_set|
    prev_set.code == set.code and prev_set.exists
  end
  next if exists and not set.code == set_code

  # request to api to get card names
  types, nfs = get_names(set.code)
  types.each do |type|
    if not card_types.find(type.set_code, type.number)
      card_types.add(type)
    end
  end

  nfs.each do |nf|
    notfounds << nf
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

  # update 
  File.open(File.expand_path( '../../db/notfounds', __FILE__ ), "w") do |file|
    file.write(Marshal.dump(notfounds))
  end

end
