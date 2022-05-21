class SlowLandCard < Card

  def resolve(side, hands, plays, deck)
    super(side, hands, plays, deck)
    num = 0
    for card in plays do
      next if card == self
      num += 1 if card.is_land?
      break if num >= 2
    end

    if num == 2
      @tapped = false
    else
      @tapped = true
    end
  end

  def step_in_plays(turn)
    super(turn)
    @tapped = false
  end

  def tapped?
    @tapped
  end

  def reset
    super
    @tapped = false
  end
end
