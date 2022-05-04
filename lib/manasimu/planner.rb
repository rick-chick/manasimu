class Planner

  def plan(hands, fields)
    lands_in_hand = lands(hands)

    max_price =  0
    max_spells = nil
    max_land = nil

    if not lands_in_hand.empty?
      lands_in_hand.each do |play_land|
        # dup
        current_hands = hands.dup
        current_fields = fields.dup

        # play the land
        current_hands.delete play_land
        current_fields << play_land

        # search_opt_spells
        price, spells = 
          search_opt_spells(current_hands, current_fields)
        if price >= max_price and not spells.empty?
          max_price = price
          max_spells = spells
          max_land = play_land
        end
      end
    else
      # search_opt_spells
      max_price, max_spells = search_opt_spells(hands, fields)
    end

    if not max_spells and not lands_in_hand.empty?
      max_land = lands_in_hand[0]
    end

    [max_land, max_spells].select {|a| a}.flatten
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
      b.color_identity_size <=> a.color_identity_size
    end

    price = 0
    bit_lands = 0
    bit_spells = 0
    # search playable spell comibantion
    cost, bit_spells, bit_lands =
      dfs(1, spells, lands, bit_spells, bit_lands, price)
    [price, bit_select(spells, bit_spells)]
  end

  def dfs(n, spells, lands, bit_spells, bit_lands, price)
    index = n - 1

    # exit
    return [price, bit_spells, bit_lands] if n > spells.length

    spell = spells[index]
    # ex) lands [a,b,c,d]
    #     bit_lands is 3 ( = 0011)
    #     then left_lands to be [c, d]
    left_lands = bit_select(lands, reverse_bit(bit_lands, lands.length))

    # cast case
    is_playable, used_lands = spell.playable?(left_lands)
    a_price, a_bit_spells, a_bit_lands = 
      if is_playable
        bit_spells = bit_spells | 1 << ( n - 1 )
        # ex) lands [a,b,c,d]
        #      bit_lands 3 ( = 0011)
        #     used_lands [d]
        #     then used_lands to be [0,0,0,d]
        used_lands = fill_used_lands(used_lands, bit_lands, lands)
        # ex) used_lands [0,0,0,d]
        #     bit_lands 3 ( = 0011)
        #     then bit_lands to be 11 ( = 1011)
        bit_lands = update_bit(used_lands, bit_lands)
        # dfs
        dfs(n + 1 , spells, lands, bit_spells, bit_lands, price + spell.price)
      else
        [nil, nil, nil]
      end

    # not cast case
    b_price, b_bit_spells, b_bit_lands = 
      dfs(n + 1 , spells, lands, bit_spells, bit_lands, price)

    if (a_price and a_price >= b_price)
      [a_price, a_bit_spells, a_bit_lands]
    else
      [b_price, b_bit_spells, b_bit_lands]
    end
  end

  def reverse_bit(bit, length)
    s = bit.to_s(2)
    length.times.to_a.map do |i|
      if s[i] and s[i] == "1"
        "0"
      else
        "1"
      end
    end.join.to_i(2)
  end

  def bit_select(cards, bit)
    cards.length.times
          .map { |i| cards[i] if (bit & (1 << i) > 0) }
          .select { |o| o }
  end

  def update_bit(used_lands, bit_lands)
    used_lands.each_with_index do |flg, i|
      bit_lands = bit_lands | ( 1 << i ) if flg == 1
    end
    bit_lands
  end

  def fill_used_lands(used_lands, bit_lands, lands)
    result = []
    j = 0
    lands.length.times do |i|
      if (bit_lands & 1 << i) == 1
        # used before dfs
        result << 1
      else
        # used after dfs
        result << used_lands[j]
        j += 1
      end
    end
    result
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
