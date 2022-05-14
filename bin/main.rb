require_relative '../lib/manasimu.rb'

deck, card_types = 
  File.open('cardlist.txt', 'r') do |file|
    Deck.create(file.readlines)
  end

config = SimulatorConfig.new
config.simulations = 1000
config.turns = 10
config.deck = deck

simulator = Simulator.new(config)
simulator.run

card_types.each do |spell|
  played, drawed, can_played = spell.count()
  played_in_game = played.to_f / config.simulations * 100
  played_if_draw = played.to_f / drawed * 100
  can_played_if_draw = can_played.to_f / drawed * 100
  puts "#{spell.name} : #{played_if_draw.round(1)} #{played_in_game.round(1)} #{can_played_if_draw.round(1)}"
end
