class SncFetchLandCard < TapLandCard

  attr_accessor :deck

  def resolve(side, hands, plays, deck)
    super(side, hands, plays, deck)
    return @fetch_source if @fetch_source
    @tapped = true
    if deck
      @fetches = deck
        .select { |card| card.instance_of? BasicLandCard }
        .select { |card| @mana_source.include? card.mana_source[0] }
        .uniq { |card| card.card_type }
      @deck = deck
      @fetch_source = @fetches.map { |card| card.mana_source }.flatten.uniq
    else
      @fetches = []
      @fetch_source = []
    end
  end

  def first_produce_symbol=(color)
    super(color)
    if @deck
      basic_land = @deck
        .select { |card| card.instance_of? BasicLandCard }
        .select { |card| color.to_i.to_s == color || card.mana_source.include?(color) }
        .first
      if basic_land
        @deck.delete basic_land
        @deck.shuffle!
        @fetch_source = [color]
        @fetches = [basic_land]
      else
        debugger
        raise Exception.new('basic land is empty')
      end
    else
      []
    end
    @fetched = true
  end

  def mana_source
    raise Exception.new('you should resolve first') if not @fetch_source
    @fetch_source
  end

  def configure
    mana_types = ManaType.search_text_by_land_type(card_type.text)
    @mana_source = mana_types.map {|mana_type| mana_type.color}.flatten.uniq
    @fetched = false
    self
  end

  def reset
    super
    @fetched = false
    @fetch_source = nil
  end

  def mana_produced?
    @fetched
  end
end
