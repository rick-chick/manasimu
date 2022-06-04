class Deck

  def self.create(lines)
    items = Deck.input_to_card_hash(lines)
    Deck.get_card_details(items)
  end

  def self.input_to_card_hash(lines)
    result = []
    looking_for_deck_line = false
    for line in lines do
      trimmed = line.chomp
      trimmed_lower = trimmed.downcase

      # Ignore reserved words
      if trimmed_lower == "deck"
        looking_for_deck_line = false
        next
      end

      if trimmed_lower == "commander" 
        looking_for_deck_line = true
        next
      end
      if trimmed_lower == "companion" 
        looking_for_deck_line = true
        next
      end
      #Assumes sideboard comes after deck
      if trimmed_lower == "sideboard"
        break
      end
      if trimmed_lower == "maybeboard"
        # Assumes maybeboard comes after deck
        break
      end
      # Ignore line comments
      if trimmed.start_with? ('#')
        next
      end
      if looking_for_deck_line
        next
      end
      # An empty line divides the main board cards from the side board cards
      if trimmed.empty?
        break
      end

      if !(trimmed =~ /\s*(\d+)\s+([^\(#\n\r]+)(?:\s*\((\w+)\)\s+(\d+))?\s*/)
        next
      end

      deck_item = {}
      deck_item[:amount] = $1.strip
      deck_item[:name] = $2.strip
      deck_item[:set] = $3.strip
      deck_item[:setnum] = $4.strip
      result << deck_item
    end
    result
  end

  def self.card_types
    path = File.expand_path( '../../../db/card_type_aggregate', __FILE__ )
    @@card_types ||= Marshal.load(File.open(path, 'r'))
  end

  def self.find_card_types(lines)
    types = card_types.map do |a| a end
    types.sort! do |a,b| a.name <=> b.name end

    distinct_types = []
    types.each do |type|
      next if distinct_types[-1] and distinct_types[-1].name == type.name
      type.name
      distinct_types << type
    end

    ret = []
    lines.each do |line|
      line.chomp!
      [-1, 4].each do |i|
        search_type = distinct_types.bsearch do |type|
          if i == -1
            name = type.name.split(' // ')[0]
          else
            next if not type.names[i]
            name = type.names[i].split(' // ')[0]
          end

          flag = true
          name.chars.each_with_index do |nc,i|
            if line.length > i
              lc = line.chars[i]
              if nc > lc
                flag = true
                break
              elsif nc < lc
                flag = false
                break
              else
                # continue
              end
            else
              flag = true
              break
            end
          end
          flag
        end
        if search_type
          a = search_type.name.split(' // ')[0]
          if line =~ /^#{a}.*$/ and a != 'X'
            ret << search_type
            break
          end
        end
      end
    end

    ret.sort! do |a,b| a.converted_mana_cost <=> b.converted_mana_cost end
    ret.uniq!
    ret
  end

  def self.get_card_details(deck_items)
    cards = []
    card_id = 0
    clone_card_types = []
    deck_items.each do |deck_item|
      card_type = card_types.find(deck_item[:set], deck_item[:setnum])
      clone = CardType.create(card_type, deck_item[:name])
      clone_card_types << clone
      if clone.is_land?
        if clone.name =~ /.*Pathway$/
          card = PathwayCard.new(clone)
        elsif clone.contents[0].text =~ /enters the battlefield tapped\./
          card = TapLandCard.new(clone)
        elsif clone.contents[0].text =~ /enters the battlefield tapped unless you control two or more other lands./
          card = SlowLandCard.new(clone)
        elsif clone.text =~ /earch your library for a basic land card, put it onto the battlefield tapped, then shuffle/
          card = FetchLandCard.new(clone)
          card.configure
        elsif clone.set_code == 'SNC' and 
          clone.contents[0].text =~ /enters the battlefield, sacrifice it/
          card = SncFetchLandCard.new(clone)
          card.configure
        elsif clone.type[0] =~ /^Basic Land — .*$/
          card = BasicLandCard.new(clone)
        else
          card = Card.new(clone)
        end
      else
        card = Card.new(clone)
      end
      deck_item[:amount].to_i.times do 
        card_clone = card.dup
        card_clone.id = card_id
        card_id += 1
        cards << card_clone
      end
    end
    [cards, clone_card_types]
  end
end
