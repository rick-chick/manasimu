Gem::Specification.new do |s|
  s.name        = 'manasimu'
  s.version     = '0.0.38'
  s.date        = '2022-09-23'
  s.summary     = "mtg arrena mana curve simulator"
  s.description = "mtg arrena mana curve simulator"
  s.authors     = ["so1itaryrove"]
  s.email       = 'so1itaryrove@gmail.com'
  s.license     = 'MIT'
  s.files       = Dir["lib/manasimu.rb", "lib/manasimu/*.rb", "lib/manasimu/card/*.rb", "ext/manasimu/*.cpp","ext/manasimu/*.h","ext/manasimu/*.rb", "db/card_type_aggregate"]
  s.extensions << "ext/manasimu/extconf.rb"
end
