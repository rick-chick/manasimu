Gem::Specification.new do |s|
  s.name        = 'manasimu'
  s.version     = '0.0.20'
  s.date        = '2022-05-28'
  s.summary     = "mtg arrena mana curve simulator"
  s.description = "mtg arrena mana curve simulator"
  s.authors     = ["so1itaryrove"]
  s.email       = 'so1itaryrove@gmail.com'
  s.license     = 'MIT'
  s.files       = Dir["lib/manasimu.rb", "lib/manasimu/*.rb", "lib/manasimu/card/*.rb", "ext/*.so", "db/card_type_aggregate"]
end
