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
    path = File.expand_path( '../../../db/AllPrintings.sqlite', __FILE__ )
    db = SQLite3::Database.new(path)
    sql = <<DOC
    select distinct 
      name
     ,number
     ,colorIdentity
     ,side
     ,setCode
     ,manaCost
     ,types 
     ,text
     ,convertedManaCost
    from cards 
    where 
      number = ? and
      setCode = ?
DOC
    cards = []
    card_id = 0
    card_types = CardTypeAggregate.new
    deck_items.each do |deck_item|
      rows = db.execute(sql, deck_item[:setnum], deck_item[:set])
      if rows.empty?
        puts deck_item[:name]
      end

      card_type = card_types.find(
        CardType.new(rows.map { |row|
          {
            name: row[0],
            number: row[1],
            color_identity: row[2],
            side: row[3],
            set_code: row[4],
            mana_cost: row[5],
            types: row[6],
            text: row[7],
            converted_mana_cost: row[8]
          }
        })
      )
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
