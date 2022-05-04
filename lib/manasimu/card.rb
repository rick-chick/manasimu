class Card
  attr_accessor :id, :card_type

  def initialize(card_type)
    @card_type = card_type
  end

  def step(turn)
  end

  def drawed(turn)
    @drawed = turn
    @card_type.drawed(turn)
  end

  def played(turn)
    @played = turn
    @card_type.played(turn)
  end
  def played?
    @played.nil?
  end

  def tapped?
    false
  end

  def mana_source?
    @card_type.mana_source?
  end

  def playable?(lands)
    @card_type.playable?(lands)
  end

  def types
    @card_type.types
  end

  def mana
    @card_type.mana
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

  def max_flow(lands)
    @card_type.max_flow(lands)
  end

  def edges(lands)
    @card_type.edges(lands)
  end

  def to_s
    @card_type.to_s
  end
end

class CardType
  attr_accessor :contents

  def initialize(contents)
    return if not contents
    @contents = contents.map {|c| Content.new(c)}
  end

  def name
    @name ||= @contents[0].name
  end

  def played(turn)
    @played ||= {}
    @played[turn] ||= 0
    @played[turn] += 1
  end

  def drawed(turn)
    @drawed ||= {}
    @drawed[turn] ||= 0
    @drawed[turn] += 1
  end

  def mana_source?
    @mana_source ||= @contents.any? {|content| content.mana_source?}
  end

  def types
    @types ||= @contents.map {|c| c.types}
  end

  def mana
    @mana ||= @contents.map {|content| content.color_identity }.flatten
  end

  def color_identity
    return @memo_colors if @memo_colors
    @memo_colors ||= []
    @contents.each do |c|
      c.color_identity.split(",").each do |color|
        @memo_colors << color if not @memo_colors.include? color
      end
    end
    @memo_colors
  end

  def converted_mana_cost
    @converted_mana_cost ||= @contents.map {|c| c.converted_mana_cost}.min
  end

  def color_identity_size
    color_identity.length
  end

  def mana_cost
    @mana_cost ||= @contents.select {|c| c.types != "Land"}.first.mana_cost
  end

  def price
    converted_mana_cost
  end

  def playable?(lands)
    return [false, []] if lands.empty?
    return [false, []] if converted_mana_cost > lands.length
    mf, used = max_flow(lands)
    [mf == converted_mana_cost, used.to_a[1..lands.length]]
  end

  def max_flow(lands)
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
    x, y, e = edges(lands)
    g = Graph.new(x + y + 2)
    e.each do |s, d|
      g.add_edge(s, d, 1)
    end

    ret = obj.max_flow(g, 0, x + y + 1)
    [ret, obj.used]
  end

  def edges(lands)
    result = []
    x = lands.length
    i_src = 0
    # source connect to lands
    x.times do |i|
      result << [i_src, i + 1]
    end

    # create symbol
    symbols = []
    mana_cost[1..-2].split('}{').each_with_index do |mana, j|
      spell_colors = mana.split('/')
      if spell_colors.length == 1 
        spell_color = spell_colors[0]
        if spell_color.to_i.to_s == spell_color
          # numeric symbol
          spell_color.to_i.times do |k|
            symbols << "1"
          end
        else
          # color symbol
          symbols << spell_color
        end
      else
        # multi symbol
        throw Exception.new('unprogramed exception')
      end
    end

    # lands and mana_cost connect to each symbols
    lands.each_with_index do |land, i|
      land_colors = land.color_identity
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
    played = @played ? @played [turn] : 0
    drawed = 0
    if (@drawed)
      (turn+1).times do |i|
        next if not @drawed[i]
        drawed += @drawed[i]
      end
    end
    [played, drawed]
  end

  def to_s
    @contents.map {|c| c.to_s}.join(",")
  end
end

class CardTypeAggregate

  def find(card_type)
    @memo ||= []
    return nil if not card_type
    singleton = @memo.find do |c|
      a = c.contents[0]
      b = card_type.contents[0]
      a and b and a.name == b.name
    end
    if singleton
      singleton
    else
      @memo << card_type
      card_type
    end
  end

  def each
    return if not @memo
    @memo.each do |item|
      yield item
    end
  end

end

class Content
  attr_accessor :name, :number, :side, :set_code, :mana_cost, :types, :color_identity, :converted_mana_cost, :text

  def initialize(hash)
    @name = hash[:name]
    @number = hash[:number]
    @side = hash[:side]
    @set_code = hash[:set_code]
    @mana_cost = hash[:mana_cost]
    @types = hash[:types]
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
end

class FordFulkersonSingleton
  include Singleton
  def obj
    @memo_obj ||= FordFulkerson.new
  end
end
