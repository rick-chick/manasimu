class Planner

  def plan(hands, fields, deck)
    lands_in_hand = lands(hands)

    max_price =  0
    max_spells = nil
    max_land = nil
    max_symbols = nil
    max_lands = nil

    if not lands_in_hand.empty?
      lands_in_hand.each do |play_land|
        # dup
        current_hands = hands.dup
        current_fields = fields.dup
        current_deck = deck.dup

        # play the land
        current_hands.delete play_land
        current_fields << play_land
        play_land.resolve(nil, current_hands, current_fields, current_deck)

        # search_opt_spells
        price, spells, symbols, lands = 
          search_opt_spells(current_hands, current_fields)
        if price >= max_price and not spells.empty?
          max_price = price
          max_spells = spells
          max_land = play_land
          max_symbols = symbols
          max_lands = lands
        end

        play_land.reset
      end
    else
      # search_opt_spells
      max_price, max_spells, max_symbols, max_lands = search_opt_spells(hands, fields)
    end

    if not max_spells and not lands_in_hand.empty?
      max_land = lands_in_hand[0]
    end

    deck = nil
    if max_lands
      max_lands.each_with_index do |land, i|
        if not land.mana_produced? and max_symbols[i]
          land.first_produce_symbol = max_symbols[i]
          deck = land.deck if land.respond_to? :deck
        end
      end
    end

    [[max_land, max_spells].select {|a| a}.flatten, deck]
  end

  #
  # on conditional playing land, search most 
  # high price spells combinations
  # return price, spells
  #
  def search_opt_spells(hands, fields)
    spells = spells(hands)
    lands = lands(fields)

    # sort spells desc converted_mana_cost
    spells.sort! do |a, b|
      b.converted_mana_cost <=> a.converted_mana_cost
    end

    lands.sort! do |a, b|
      b.mana_source_size <=> a.mana_source_size
    end

    price = 0
    bit_lands = 0
    bit_spells = 0
    # search playable spell comibantion
    cost, bit_spells, bit_lands, land_symbols =
      dfs(1, spells, lands, bit_spells, bit_lands, price, [])
    [price, bit_select(spells, bit_spells), land_symbols, lands]
  end

  def dfs(n, spells, lands, bit_spells, bit_lands, price, total_land_symbols)
    index = n - 1

    # exit
    return [price, bit_spells, bit_lands, total_land_symbols] if n > spells.length

    spell = spells[index]
    used_lands = bit_lands.to_s(2).chars
    capas = lands.length.times.to_a.map do |i|
      if used_lands[i] == "1"
        "0"
      else
        lands[i].tapped? ? "0" : "1"
      end
    end

    # shrink
    # lands_available = []
    # lands.length.times do |i|
    #   next if used_lands[i] == "1"
    #   lands_available << lands[i]
    # end
    # capas = ("1" * lands_available.length).chars

    # cast case
    is_playable, casted_lands, land_symbols = 
      spell.playable?(lands, capas)

    # expand
    # used_lands_ = []
    # land_symbols_ = []
    # j = 0
    # lands.length.times do |i|
    #   if used_lands[i] == "1" or not casted_lands
    #     used_lands_ << "1"
    #     land_symbols_ << total_land_symbols[i]
    #   else
    #     used_lands_ << casted_lands[j]
    #     land_symbols_ << land_symbols[j]
    #     j += 1
    #   end
    # end if lands

    a_price, a_bit_spells, a_bit_lands, a_land_symbols = 
      if is_playable

        bit_spells = bit_spells | 1 << ( n - 1 )
        bit_lands_ = casted_lands
          .reverse
          .map {|i| i.to_s}
          .join('')
          .to_i(2)

        land_symbols_ = lands.length.times.to_a.map do |i|
          land_symbols[i] ? land_symbols[i] : total_land_symbols[i]
        end

        # dfs
        dfs(n + 1 , spells, lands, bit_spells, bit_lands_, 
            price + spell.price, land_symbols_)
      else
        [nil, nil, nil, nil]
      end

    # not cast case
    b_price, b_bit_spells, b_bit_lands, b_land_symbols = 
      dfs(n + 1 , spells, lands, bit_spells, bit_lands, price, total_land_symbols)

    if (a_price and a_price >= b_price)
      [a_price, a_bit_spells, a_bit_lands, a_land_symbols]
    else
      [b_price, b_bit_spells, b_bit_lands, b_land_symbols]
    end
  end

  def bit_select(cards, bit)
    cards.length.times
          .map { |i| cards[i] if (bit & (1 << i) > 0) }
          .select { |o| o }
  end

  def lands(list)
    list.select do |card|
      card.types.include? "Land"
    end
  end

  def spells(list)
    list.select do |card|
      not card.types.include? "Land"
    end
  end
end
