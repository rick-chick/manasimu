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
    ret = []

    distinct_types = []
    card_types.each do |type|
      next if distinct_types[-1] and distinct_types[-1].name == type.name
      distinct_types << type
    end

    en = -1
    ja = 0

    [en, ja].each do |language|

      distinct_types.sort! do |a,b| 
        if language == en
          a.name <=> b.name 
        elsif language == ja
          d = a.name_ja_split.length <=> b.name_ja_split.length
          if d == 0
            a.name_ja_split <=> b.name_ja_split
          else
            d
          end
        else
          # none
        end
      end

      lines.each do |line|
        line.chomp!
        line.chomp.strip!
        line.chomp.lstrip!
        line.gsub!(/ \d+$/, '')

        if line =~ /^[\/,\|\d-]*$/ or line =~ /^x\d+$/
          next 
        end

        search_type = 
          if language == en
            # binary search
            distinct_types.bsearch do |type|
              name = type.name.split(' // ')[0]
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
          else language == ja
            # Levenshtein distance
            
            line.gsub!(/[①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬●〇▼▽▲△]+/, '')
            line.chomp!
            line.strip!
            line.lstrip!

            len = line.length

            s_index = distinct_types.bsearch_index do |type|
              name = type.name_ja_split
              name.length >= len - 2
            end

            e_index = distinct_types.bsearch_index do |type|
              name = type.name_ja_split
              name.length >= len + 2
            end

            next if not s_index

            min = Float::MAX
            min_type = nil

            distinct_types[s_index..e_index].each do |type|
              name = type.name_ja_split

              check_indexies = []
              if name.length == 1
                check_indexies[0] = 0
              elsif name.length == 2
                check_indexies[0] = 0
                check_indexies[1] = 1
              elsif name.length > 0
                check_indexies[0] = 0
                check_indexies[1] = (name.length / 2).to_i
                check_indexies[2] = name.length - 1
              end

              next if check_indexies.length == 0

              include_some = false
              check_indexies.each do |idx|
                if not name[idx].empty? and line.index(name[idx])
                  include_some = true
                  break
                end
              end

              next if not include_some

              d = levenshtein(line, name)
              base =  [name.length, line.length].max
              diff_rate =  d.to_f / base
              if diff_rate < min
                min = diff_rate
                min_type = type
              end
              if d == 0
                break
              end
            end

            result = nil

            if min_type and min <= 0.3
              result = min_type
            end

            result
          end

        if search_type
          if language == en
            a = search_type.name.split(' // ')[0]
            if line =~ /^#{a}.*$/ and a != 'X'
              ret << search_type
            end
          elsif language == ja
            ret << search_type
          else
            # none
          end
        end
      end
    end

    ret.sort! do |a,b| a.converted_mana_cost <=> b.converted_mana_cost end
    ret.uniq!
    ret
  end

  def self.tsearch(arr, line, low, high)
    if high - low < 1000
      return [low, high]
    end
    c1 = ((low * 2 + high ) / 3).to_i - 1
    c2 = ((low + high * 2 ) / 3).to_i + 1

    n1 = arr[c1].name_ja_split
    n2 = arr[c2].name_ja_split
    
    y1 = levenshtein(line, n1)
    y2 = levenshtein(line, n2)
    if y1 > y2
      tsearch(arr, line, c1, high)
    else
      tsearch(arr, line, low, c2)
    end
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

  def self.levenshtein(first, second)
    matrix = [(0..first.length).to_a]
    (1..second.length).each do |j|
      matrix << [j] + [0] * (first.length)
    end

    (1..second.length).each do |i|
      (1..first.length).each do |j|
        if first[j-1] == second[i-1]
          matrix[i][j] = matrix[i-1][j-1]
        else
          matrix[i][j] = [
            matrix[i-1][j],
            matrix[i][j-1],
            matrix[i-1][j-1],
          ].min + 1
        end
      end
    end
    return matrix.last.last
  end
end
