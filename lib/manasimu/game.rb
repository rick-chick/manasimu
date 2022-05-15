class Game
  attr_accessor :hands, :plays, :deck

  def initialize(deck, shuffle = true)
    if shuffle 
      @deck = deck.shuffle(random: Random.new)
    else
      @deck = deck
    end
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

    draw(turn)
    play_cards = plan;
    @hands.each { |card| card.step_in_hands(turn) }
    plan.each do |card| 
      play(card, turn)
    end
    @plays.each { |card| card.step_in_plays(turn) }
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
