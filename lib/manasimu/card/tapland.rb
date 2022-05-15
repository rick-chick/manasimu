class TapLandCard < Card

  def tapped?
    @tapped
  end

  def resolve(side, hands, plays)
    @tapped = true
  end

  def step(turn)
    @tapped = false
  end

  def reset
    super
    @tapped = false
  end
end
