require_relative "../lib/manasimu.rb"
require 'sqlite3'

def all_card_details(where = nil, condition = nil)
  path = File.expand_path( '../../db/AllPrintings.sqlite', __FILE__ )
  db = SQLite3::Database.new(path)
  sql = <<DOC
  select distinct 
    name
   ,number
   ,colorIdentity
   ,side
   ,setCode
   ,manaCost
   ,type
   ,types 
   ,text
   ,convertedManaCost
  from cards 
  #{"where " + where if where}
  group by
    name
   ,number
   ,colorIdentity
   ,side
   ,setCode
   ,manaCost
   ,type
   ,types 
   ,text
   ,convertedManaCost
  order by
    setCode
   ,cast(number as integer)
   ,side
DOC
  card_types = CardTypeAggregate.new
  rows = db.execute(sql, condition)
  length = rows.length
  i = 0
  rows.to_a.group_by {|c| [c[1],c[4]] }.each do |key, card|
    puts (i.to_f / length * 100).round(1) if i % 1000 == 0
    i += 1
    if not card_types.find(card[0][4], card[0][1].to_i)
      card_types.add(CardType.new(card.map { |row|
        {
          name: row[0],
          names: [],
          number: row[1].to_i,
          color_identity: row[2],
          side: row[3],
          set_code: row[4],
          mana_cost: row[5],
          type: row[6],
          types: row[7],
          text: row[8],
          converted_mana_cost: row[9]
        }
      }))
    end
  end
  card_types
end
