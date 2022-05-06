require_relative "../lib/manasimu.rb"
require 'sqlite3'

def all_card_details
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
   ,types 
   ,text
   ,convertedManaCost
  from cards 
  group by
    name
   ,number
   ,colorIdentity
   ,side
   ,setCode
   ,manaCost
   ,types 
   ,text
   ,convertedManaCost
  order by
    setCode
   ,cast(number as integer)
   ,side
DOC
  card_types = CardTypeAggregate.new
  rows = db.execute(sql)
  length = rows.length
  i = 0
  rows.to_a.group_by {|c| [c[1],c[4]] }.each do |key, card|
    puts (i.to_f / length * 100).round(1) if i % 1000 == 0
    i += 1
    if not card_types.find(card[0][4], card[0][1])
      card_types.add(CardType.new(card.map { |row|
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
      }))
    end
  end
  card_types
end

card_types = all_card_details

File.open(File.expand_path( '../../db/card_type_aggregate', __FILE__ ), "w") do |file|
  file.write(Marshal.dump(card_types))
end

