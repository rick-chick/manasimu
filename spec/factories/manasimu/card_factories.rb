FactoryBot.define do

  initialize_with { new({}) }

  factory :spiritmonger, class: Card do
    card_type { association(:spiritmonger_type)}
  end

  factory :black_creature, class: Card do
    card_type { association(:black_creature_type) }
  end

  factory :naturalize, class: Card do
    card_type { association(:naturalize_type) }
  end

  factory :blackmail, class: Card do
    card_type { association(:blackmail_type) }
  end

  factory :swamp, class: BasicLandCard do
    card_type { association(:swamp_type) }
  end

  factory :forest, class: BasicLandCard do
    card_type { association(:forest_type) }
  end

  factory :mountain, class: BasicLandCard do
    card_type { association(:mountain_type) }
  end

  factory :island, class: BasicLandCard do
    card_type { association(:island_type) }
  end

  factory :plains, class: BasicLandCard do
    card_type { association(:plains_type) }
  end

  factory :darkbore_pathway_card, class: PathwayCard do
    card_type { association(:darkbore_pathway_type) }
  end

  factory :jungle_hollow_card, class: TapLandCard do
    card_type { association(:jungle_hollow_type) }
  end

  factory :deathcap_glade_card, class: SlowLandCard do
    card_type { association(:deathcap_glade_type) }
  end

  factory :obscura_storefront_card, class: SncFetchLandCard do
    card_type { association(:obscura_storefront_type) }
  end
end
