class SncFetchLandCard < FetchLandCard

  def configure
    mana_types = ManaType.search_text_by_land_type(card_type.text)
    super.mana_source = mana_types.map {|mana_type| mana_type.color}.flatten.uniq
    self
  end
end
