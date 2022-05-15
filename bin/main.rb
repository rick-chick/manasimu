require_relative '../lib/manasimu.rb'

deck, card_types = 
  File.open('cardlist.txt', 'r') do |file|
    Deck.create(file.readlines)
  end

config = SimulatorConfig.new
config.simulations = 100
config.turns = 10
config.deck = deck

simulator = Simulator.new(config)
simulator.run

card_types.each do |spell|
  played, drawed, can_played, mana_sources = spell.count()
  played_in_game = played.to_f / config.simulations * 100
  played_if_draw = played.to_f / drawed * 100
  can_played_if_draw = can_played.to_f / drawed * 100
  puts "#{spell.name} : #{played_if_draw.round(1)} #{played_in_game.round(1)} #{can_played_if_draw.round(1)}"
end

puts 
puts "mana curve"
mana_curves = {}
card_types.map do |card|
  if card.mana_source?
    10.times do |i|
      turn = i + 1
      played, drawed, can_play, mana_sources = card.count(turn)
      card.color_identity.each do |c|
        mana_curves[c] ||= {}
        mana_curves[c][turn] ||= 0
        mana_curves[c][turn] += mana_sources[c].to_f / config.simulations
      end
    end
  end
end
mana_curves = mana_curves.keys.map do |c|
  puts c
  puts mana_curves[c].values
end
