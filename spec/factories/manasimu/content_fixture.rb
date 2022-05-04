FactoryBot.define do

  factory :blackmail_content, class: Content do
    name  {'Blackmail'}
    number {'115'}
    side {''}
    set_code { '9ED'}
    mana_cost { '{B}'}
    types { 'Sorcery'}
    text { 'Target player reveals three cards from their hand and you choose one of them. That player discards that card.'}
    color_identity { 'B'}
    converted_mana_cost {1}
  end

  factory :naturalize_content, class: Content do
    name  {'Naturalize'}
    number {'282'}
    side {''}
    set_code { '10E'}
    mana_cost { '{1}{G}'}
    types { 'Instant'}
    text { ''}
    color_identity { 'G'}
    converted_mana_cost {2}
  end

  factory :spiritmonger_content, class: Content do
    name  {'Spiritmonger'}
    number {'121'} 
    side {''}
    set_code { 'APC'}
    mana_cost { '{3}{B}{G}'}
    types { 'Creature'}
    text { 'Whenever Spiritmonger deals damage to a creature, put a +1/+1 counter on Spiritmonger.
    {B}: Regenerate Spiritmonger.
    {G}: Spiritmonger becomes the color of your choice until end of turn.'}
    color_identity { 'B,G'}
    converted_mana_cost {5}
  end

  factory :black_creature_content, class: Content do
    name  {'Unyielding Krumar'}
    number {'807'}
    side {''}
    set_code { 'MB1'}
    mana_cost { '{3}{B}'}
    types { 'Creature'}
    text { '{1}{W}: Unyielding Krumar gains first strike until end of turn.'}
    color_identity { 'B,W'}
    converted_mana_cost { 4}
  end

  factory :swamp_content, class: Content do
    name  {'Swamp'}
    number {'260'}
    side {''}
    set_code { 'M15'}
    mana_cost { ''}
    types { 'Land'}
    text { '({T}: Add {B}.)'}
    color_identity { 'B'}
    converted_mana_cost { 0}
  end

  factory :forest_content, class: Content do
    name  {'Forest'}
    number {'380'}
    side {''}
    set_code { '10E'}
    mana_cost { ''}
    types { 'Land'}
    text { '({T}: Add {G}.)'}
    color_identity { 'G'}
    converted_mana_cost { 0}
  end
end
