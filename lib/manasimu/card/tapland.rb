class TapLandCard < Card

  def tapped?
    @tapped
  end

  def drawed(turn)
    super(turn)
    @tapped = true
  end

  def step(turn)
    @tapped = false
  end
end
