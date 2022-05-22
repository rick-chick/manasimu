class TapLandCard < Card

  def tapped?
    @tapped
  end

  # when enter the battlefield
  def resolve(side, hands, plays, deck)
    super(side, hands, plays, deck)
    @tapped = true
  end

  def step_in_plays(turn)
    super(turn)
    @tapped = false
  end

  def tappend=(tapped)
    @tapped = tapped
  end

  def reset
    super
    @tapped = false
  end
end
