class Card
  attr_accessor :id, :card_type, :side

  def initialize(card_type)
    @card_type = card_type
    @playable = false
  end

  def configure
  end

  def step_in_hands(turn)
    @card_type.step_in_hands(turn, self)
    @can_play = false
  end

  def step_in_plays(turn)
    @card_type.step_in_plays(turn, self)
  end

  def drawed(turn)
    @drawed = turn
    @card_type.drawed(turn)
  end

  def played(turn, side = "a")
    @played = turn
    @side = side
    if not is_land? or not tapped?
      @card_type.played(turn)
    end
  end

  def resolve(side = "a", hands, plays, deck)
  end

  def played?
    @played.nil?
  end

  def tapped?
    false
  end

  def mana_source
    @card_type.mana_source
  end

  def mana_source_size
    @card_type.mana_source_size
  end

  def mana_source?
    @card_type.mana_source?
  end

  def playable?(lands, capas)
    ret = @card_type.playable?(lands, capas)
    @can_play = true if ret and ret[0]
    ret
  end

  def can_play?
    @can_play
  end

  def types
    @card_type.types
  end

  def type
    @card_type.type
  end

  def color_identity
    @card_type.color_identity
  end

  def converted_mana_cost
    @card_type.converted_mana_cost
  end

  def color_identity_size
    @card_type.color_identity_size
  end

  def mana_cost
    @card_type.mana_cost
  end

  def price
    @card_type.price
  end

  def reset
    @side = nil
    @played = nil
    @drawed = nil
    @can_play = false
  end

  def is_land?
    @card_type.is_land? @side
  end

  def max_flow(lands, capas)
    @card_type.max_flow(lands, capas)
  end

  def edges(lands, capas)
    @card_type.edges(lands, capas)
  end

  def mana_produced?
    @side
  end

  def first_produce_symbol=(symbol)
  end

  def set_code
    @card_type.set_code
  end

  def to_s
    @card_type.to_s
  end
end

class CardType
  attr_accessor :contents, :played, :drawed, :name, :can_plays, :mana_sources

  def self.create(card_type, name)
    ret = card_type.dup
    ret.contents = card_type.contents
    ret.played = {}
    ret.drawed = {}
    ret.can_plays = {}
    ret.mana_sources = {}
    ret.name = name
    ret
  end

  def initialize(contents)
    return if not contents
    @played = {}
    @drawed = {}
    @can_plays = {}
    @mana_sources = {}
    @contents = contents.map {|c| Content.new(c)}
  end

  def name
    @name ||= @contents[0].name
  end

  def step_in_hands(turn, card)
    if card.can_play?
      @can_plays[turn] ||= 0
      @can_plays[turn] += 1
    end
  end

  def step_in_plays(turn, card)
    if card.mana_source? and not card.tapped?
      @mana_sources[turn] ||= {}
      size = card.mana_source.length
      card.mana_source.each do |c|
        @mana_sources[turn][c] ||= 0
        @mana_sources[turn][c] += 1.0 / size
      end
    end
  end

  def played(turn)
    @played[turn] ||= 0
    @played[turn] += 1
  end

  def drawed(turn)
    @drawed[turn] ||= 0
    @drawed[turn] += 1
  end

  def mana_source
    @mana_source ||= @contents.map { |c| 
        c.color_identity ? c.color_identity.split(',') : []
      }.flatten.uniq
  end

  def mana_source_size
    (a = mana_source) ? a.size : 0
  end

  def mana_source?
    @is_mana_source ||= @contents.any? {|content| content.mana_source?}
  end

  def mana_cost
    return @mana_cost if @mana_cost
    spell = @contents.select {|c| c.types != "Land"}.first
    if spell
      @mana_cost = spell.mana_cost
    else
      @mana_cost = '0'
    end
  end

  def converted_mana_cost
    @converted_mana_cost ||= @contents.map {|c| c.converted_mana_cost}.min
  end

  def text
    @text ||= @contents.map {|c| c.text}.flatten.join('')
  end

  def type
    @type ||= @contents.map {|c| c.type}.flatten.uniq
  end

  def types
    @types ||= @contents.map {|c| c.types}
  end

  def color_identity
    return @memo_colors if @memo_colors
    @memo_colors ||= []
    @contents.each do |c|
      if c.color_identity
        c.color_identity.split(",").each do |color|
          @memo_colors << color if not @memo_colors.include? color
        end
      end
    end
    @memo_colors
  end

  def color_identity_size
    color_identity.length
  end

  def symbols
    return @symbols if @symbols
    @symbols = []
    mana_cost[1..-2].split('}{').each_with_index do |mana, j|
      spell_colors = mana.split('/')
      if spell_colors.length == 1 
        spell_color = spell_colors[0]
        if spell_color.to_i.to_s == spell_color
          # numeric symbol
          spell_color.to_i.times do |k|
            @symbols << "1"
          end
        else
          # color symbol
          @symbols << spell_color
        end
      else
        # multi symbol
        throw Exception.new('unprogramed exception')
      end
    end
    @symbols
  end

  def price
    converted_mana_cost
  end

  def set_code
    @contents[0].set_code
  end

  def is_land?(side = nil)
    return @is_land if @is_land
    arr = if side == 'a'
            [0]
          elsif side == 'b'
            [1]
          else
            [0,1]
          end
    @is_land = arr.select do |i|
      @contents[i] and @contents[i].types == "Land"
    end.length > 0
    return @is_land
  end

  def playable?(lands, capas)
    return [false, [], []] if lands.empty?
    return [false, [], []] if converted_mana_cost > lands.length
    mf, used, land_symbols = max_flow(lands, capas)
    [mf == converted_mana_cost, used.to_a[1..lands.length], land_symbols]
  end

  def max_flow(lands, capas)
    obj = FordFulkersonSingleton.instance.obj
    # Graph has x+y+2 nodes
    # source       : 0
    # lands        : 1 - x 
    # mana_cost    : x+1 - x+y+1 
    # destination  : x+y+2
    #
    # image
    #         - land1  - mana4 
    # source0 - land2  - mana5 - destination6
    #         - land3 
    #

    # create edge
    x, y, e = edges(lands, capas)
    g = Graph.new(x + y + 2)
    e.each do |s, d|
      g.add_edge(s, d, 1)
    end

    ret = obj.max_flow(g, 0, x + y + 1)

    land_symbols = Array.new(lands.length)
    for edges in g.G do
      for edge in edges do
        if edge.cap == 0 and edge.from.between?(1, x) and edge.to.between?(x+1, x+y)
          land_index = edge.from - 1
          spell_index = edge.to - x - 1
          land_symbols[land_index] = symbols[spell_index] 
        end
      end
    end

    [ret, obj.used, land_symbols]
  end

  def edges(lands, capas)
    result = []
    x = lands.length
    i_src = 0
    # source connect to lands
    x.times do |i|
      result << [i_src, i + 1]
    end

    # lands and mana_cost connect to each symbols
    lands.each_with_index do |land, i|
      next if capas[i].to_i == 0
      land_colors = land.mana_source
      symbols.each_with_index do |symbol, j|
        if symbol == "1" or land_colors.include? symbol
          result << [i + 1, x + 1 + j]
        end
      end
    end

    y = symbols.length 
    i_dst = x + y + 1

    # mana_cost connect to destination
    y.times do |i|
      result << [x + 1 + i, i_dst]
    end

    [x, y, result]
  end

  def count(turn = nil)
    turn ||= converted_mana_cost
    played_count = @played[turn] || 0
    drawed_count = 0
    (turn+1).times do |i|
      drawed_count += @drawed[i] || 0
    end
    can_played_count = @can_plays[turn] || 0
    mana_sources_count = @mana_sources[turn] || {}
    [played_count, drawed_count, can_played_count, mana_sources_count]
  end

  def to_s
    @contents.map {|c| c.to_s}.join(",")
  end

  def to_factory
    @contents.map {|c| c.to_factory}
  end
end

class CardTypeAggregate

  def find(set_code, number)
    @memo ||= []
    @memo.find do |c|
      a = c.contents[0]
      a and a.set_code == set_code and a.number == number
    end
  end

  def add(card_type)
    @memo ||= []
    @memo << card_type
  end

  def each
    return if not @memo
    @memo.each do |item|
      yield item
    end
  end

  def map
    @memo.map do |item|
      yield item
    end
  end
end

class Content
  attr_accessor :name, :number, :side, :set_code, :mana_cost, :type, :types, :color_identity, :converted_mana_cost, :text

  def initialize(hash)
    @name = hash[:name]
    @number = hash[:number]
    @side = hash[:side]
    @set_code = hash[:set_code]
    @mana_cost = hash[:mana_cost]
    @types = hash[:types]
    @type = hash[:type]
    @text = hash[:text]
    @color_identity = hash[:color_identity]
    @converted_mana_cost = hash[:converted_mana_cost].to_i
  end

  def mana_source?
    return @types == "Land"
  end

  def to_s
    "[#{@name}] [#{@types}] [#{@color_identity}] [#{@mana_cost}]"
  end

  def to_factory
    <<EOF
  factory '#{@name.underscore}_content', class: Content do
    name  {'#{@name}'}
    number {'#{@number}'}
    side {'#{@side}'}
    set_code { '#{@set_code}'}
    mana_cost { '#{@mana_cost}'}
    type { '#{@type}'}
    types { '#{@types}'}
    text { '#{@text}'}
    color_identity { '#{@color_identity}'}
    converted_mana_cost {#{@converted_mana_cost}}
  end
EOF
  end

end

class FordFulkersonSingleton
  include Singleton
  def obj
    @memo_obj ||= FordFulkerson.new
  end
end
