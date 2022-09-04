require 'uri'
require 'json'
require 'net/http'

API_URL = 'https://api.magicthegathering.io/v1/'
HTML_URL = 'https://gatherer.wizards.com/'

def request_cards(set_code, page)
  begin
    uri = URI(API_URL + "cards")
    params = { page: page, pageSize: 100, set: set_code}
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)

    if not res.is_a?(Net::HTTPSuccess)
      puts 'http connection fail'
      exit
    end

    JSON.parse(res.body)
  rescue => ex
    p ex
    sleep 30
    request_cards(set_code, page)
  end
end

def get_names(set_code)
  page = 1
  ret = []
  notfounds = []

  ja = 4
  en = 0

  while true
    hash = request_cards(set_code, page)

    if hash['cards'].length == 0
      puts 'last page'
      break
    end

    multiverseid_offset = nil
    multiverseid_change_count = 0
    ja_index = nil

    unfound_cards = []
    hash['cards'].each do |card|

      if not card['foreignNames']
        unfound_cards << card
        next
      end

      names = card['foreignNames'].select do |f|
        f['language'] == "Japanese"
      end.map do |f| 
        f["name"]
      end

      ja_index = card['foreignNames'].map do |f|
        f['language']
      end.index('Japanese')

      multiverseids = card['foreignNames'].map do |f|
        f['imageUrl'] =~ /multiverseid=(\d+)&?/
        $1
      end

      # to scrape japanese name using multiverse, get multiverse id offset 
      if multiverseids.length > 1
        offset = multiverseids[1].to_i - multiverseids[0].to_i
        if multiverseid_offset != offset
          multiverseid_offset = offset
          multiverseid_change_count += 1
        end
      end

      type = create_card_type(card, ret, names)
      ret = add_cardtypes_to(ret, type)
    end


    # if foreignNames were not found and multiverseid_offset is fixed
    if unfound_cards.length > 0 and multiverseid_change_count == 1 and ja_index
      puts "#{set_code} / #{unfound_cards.length} cards was not found"

      unfound_cards.each do |card|
        ja_multiverseid = card['multiverseid'].to_i + multiverseid_offset * (ja_index + 1) 
        ja_name = scrape_detail(ja_multiverseid)

        p "#{ja_name}: #{card['name']}"

        names = []
        if not ja_name.empty?
          names = [ja_name]
        else
          notfounds << [set_code, card['number']]
        end

        type = create_card_type(card, ret, names)
        ret = add_cardtypes_to(ret, type)
      end

    elsif unfound_cards.length > 0
      puts "invalid multiverseid change #{set_code} : #{unfound_cards.length}"
      unfound_cards.each do |card|
        notfounds << [set_code, card['number']]
        type = create_card_type(card, ret, nil)
        ret = add_cardtypes_to(ret, type)
      end
    end

    p "#{ret.length}:  #{ret.last}"
    page +=1
  end

  ret.sort!

  [ret, notfounds]
end

def add_cardtypes_to(card_types, card_type)
  return card_types if not card_type
  return card_types if card_types.find do |c|
    c.number == card_type.number
  end
  card_types << card_type
  card_types
end

def create_card_type(card, ret, names)

  side_a = ret.find do |c| 
    c.number == card['number'].to_i
  end

  side = ''
  if side_a
    side_a.contents[0].side = 'a'
    side = 'b'
  end

  type = [
    {
      name: card['name'],
      names: names,
      number: card['number'],
      side: side,
      set_code: card['set'],
      mana_cost: card['manaCost'],
      types: card['types'],
      type: card['type'],
      text: card['text'],
      color_identity: card['colorIdentity'],
      converted_mana_cost: card['cmc'],
      multiverseid: card['multiverseid'],
    }
  ]

  if side == ''
    CardType.new type
  else
    side_a.contents << Content.new(type[0])
    nil
  end
end

def request_sets(page)
  begin
    params = { page: page, pageSize: 100}
    uri = URI(API_URL + "sets")
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)

    if not res.is_a?(Net::HTTPSuccess)
      puts 'http connection fail'
      exit
    end

    JSON.parse(res.body)
  rescue => ex
    p ex
    sleep 30
    request_json(page)
  end
end

def get_sets
  ret = []
  page = 1
  while true
    hash = request_sets(page)

    if hash['sets'].length == 0
      puts 'last page'
      break
    end
    page += 1

    hash['sets'].each do |set|
      code = set['code']
      name = set['name']
      ret << [code, name]
    end
  end

  ret.sort! do |a,b| a[0] <=> b[0] end

  ret
end

def scrape_detail(multiverseid)
  begin
    ret = `curl -k 'https://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=#{multiverseid}&printed=true'`
    doc = Nokogiri::HTML.parse(ret)
    doc.xpath("//*[text()[contains(., 'Card Name:')]]/parent::*").css('div.value').to_a.map do |d|
      d.text.chomp.strip 
    end .join(" // ")
  rescue => ex
    puts ex
    sleep 30
    scrape_detail(multiverseid)
  end
end

def scrape_legalities(multiverseid)
  begin
    ret = `curl -k 'https://gatherer.wizards.com/Pages/Card/Printings.aspx?multiverseid=#{multiverseid}'`
    doc = Nokogiri::HTML.parse(ret)
    legalities = {}
    Format.all.each do |format|
      text = doc.xpath("//*[text()[contains(., '#{format.name}')]]/parent::*/td[position() = 2]").text
      legality = 
        if text
          Legality.find(text.chomp.strip.lstrip)
        else
          Legality::None
        end
      legalities[format] = legality
    end
    card_info = CardInfo.new
    card_info.legalities = legalities
    card_info
  rescue => ex
    puts ex
    sleep 30
    scrape_legalities(multiverseid)
  end
end
