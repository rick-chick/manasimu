class Game
  attr_accessor :hands, :plays, :deck

  def initialize(deck)
    @deck = deck.shuffle(random: Random.new)
    @deck.each { |card| card.reset }
    @hands = []
    @plays = []
    @planner = Planner.new
    7.times { draw(0) }
  end

  def step(turn)
    # puts "turn #{turn}"
    # puts "played"
    # @plays.each do |card| puts " #{card}" end
    # puts "hands"
    # @hands.each do |card| puts " #{card}" end

    upkeep(turn)
    draw(turn)
    plan.each do |card| 
      play(card, turn)
    end
  end

  def upkeep(turn)
    @hands.each { |card| card.step(turn) }
    @plays.each { |card| card.step(turn) }
  end

  def draw(turn)
    card = @deck.pop
    # puts "draw #{card}"
    card.drawed(turn)
    @hands << card
  end

  def plan
    @planner.plan(@hands, @plays)
  end

  def play(card, turn)
    # puts "play #{card}"
    card.resolve(nil, @hands, @plays)
    card.played(turn, nil)
    @plays << card
    @hands.delete card
  end
end
