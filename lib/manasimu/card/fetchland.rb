class FetchLandCard < TapLandCard
  attr_accessor :deck

  # enter the battlefield
  def resolve(side, hands, plays, deck)
    super(side, hands, plays, deck)
    return @fetch_source if @fetch_source
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
    basic_land = @deck
      .select { |card| card.instance_of? BasicLandCard }
      .select { |card| color.to_i.to_s == color || card.mana_source.include?(color) }
      .first
    if basic_land
      @fetched = color
      @deck.delete basic_land
      @deck.shuffle!
      @fetch_source = basic_land.mana_source
      @fetches = [basic_land]
    else
      raise Exception.new('basic land is empty')
    end
    @deck
  end

  def mana_source
    raise Exception.new('you should resolve first') if not @fetch_source
    @fetch_source
  end

  def mana_source=(m)
    @mana_source = m
  end

  def configure
    mana_types = ManaType.all
    @mana_source = mana_types.map {|mana_type| mana_type.color}.flatten.uniq
    @fetched = nil
    self
  end

  def reset
    super
    @fetched = nil
    @fetch_source = nil
  end

  def mana_produced?
    not @fetched.nil?
  end
end
