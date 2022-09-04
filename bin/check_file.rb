require_relative '../lib/manasimu.rb'

expansions = Expansion.load
card_types = Deck.card_types
notfounds = 
  File.open(File.expand_path( '../../db/notfounds', __FILE__ ), "r") do |file|
    Marshal.load(file)
  end

debugger
