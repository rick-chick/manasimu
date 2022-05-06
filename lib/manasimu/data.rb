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

  def self.get_card_details(deck_items)
    path = File.expand_path( '../../../db/card_type_aggregate', __FILE__ )
    @@card_types ||= Marshal.load(File.open(path, 'r'))
    cards = []
    card_id = 0
    card_types = []
    deck_items.each do |deck_item|
      card_type = @@card_types.find(deck_item[:set], deck_item[:setnum])
      card_types << card_type
      card = Card.new(card_type)
      deck_item[:amount].to_i.times do 
        card_clone = card.dup
        card_clone.id = card_id
        card_id += 1
        cards << card_clone
      end
    end
    [cards, card_types]
  end
end
