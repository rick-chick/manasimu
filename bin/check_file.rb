require_relative '../lib/manasimu.rb'
require_relative 'api_util.rb'

expansions = Expansion.load
card_types = Deck.card_types
notfounds = 
  File.open(File.expand_path( '../../db/notfounds', __FILE__ ), "w") do |file|
    file.write(Marshal.dump(notfounds))
  end

debugger
