class TapLandCard < Card

  def tapped?
    @tapped
  end

  def resolve(side, hands, plays)
    super(side, hands, plays)
    @tapped = true
  end

  def step_in_plays(turn)
    super(turn)
    @tapped = false
  end

  def reset
    super
    @tapped = false
  end
end
