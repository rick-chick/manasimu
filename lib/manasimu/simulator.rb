class Simulator

  def initialize(config)
    @config = config
  end

  def run
    @config.simulations.times do
      game = Game.new(@config.deck)
      @config.turns.times do |i|
        turn = i + 1
        game.step turn
      end
    end 
  end
end

class SimulatorConfig
  attr_accessor :simulations, :turns, :deck
end
