class Game
  attr_accessor :hands, :plays, :deck

  def initialize(deck, shuffle = true, debugg = false)
    if shuffle 
      @deck = deck.shuffle(random: Random.new)
    else
      @deck = deck
    end
    @deck.each { |card| card.reset }
    @hands = []
    @plays = []
    @planner = Planner.new
    @debugg = debugg
    7.times { draw(0) }
  end

  def step(turn)
    if @debugg
      puts "---------------------------------"
      puts "turn #{turn} basic_lands #{@deck.select {|c| c.instance_of? BasicLandCard}.length}"
      puts "played"
      @plays.each do |card| puts " #{card}" end
      puts "hands"
      @hands.each do |card| puts " #{card}" end
    end

    draw(turn)
    play_cards, deck = plan;
    @hands.each { |card| card.step_in_hands(turn) }
    play_cards.each do |card| 
      play(card, turn)
    end
    deck = deck if deck
    @plays.each { |card| card.step_in_plays(turn) }
  end

  def draw(turn)
    card = @deck.pop
    if @debugg
      puts "draw #{card}"
    end
    card.drawed(turn)
    @hands << card
  end

  def plan
    @planner.plan(@hands, @plays, @deck)
  end

  def play(card, turn)
    if @debugg
      puts "play #{card}"
    end

    card.resolve(nil, @hands, @plays, @deck)
    card.played(turn, nil)
    @plays << card
    @hands.delete card
  end
end
