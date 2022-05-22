FactoryBot.define do

  initialize_with { new({}) }

  factory :spiritmonger_type, class: CardType do
    contents { [association(:spiritmonger_content)] }
  end

  factory :black_creature_type, class: CardType do
    contents { [association(:black_creature_content)] }
  end

  factory :naturalize_type, class: CardType do
    contents { [association(:naturalize_content)] }
  end

  factory :blackmail_type, class: CardType do
    contents { [association(:blackmail_content)] }
  end

  factory :swamp_type, class: CardType do
    contents { [association(:swamp_content)] }
  end

  factory :forest_type, class: CardType do
    contents { [association(:forest_content)] }
  end

  factory :plains_type, class: CardType do
    contents { [association(:plains_content)] }
  end

  factory :mountain_type, class: CardType do
    contents { [association(:mountain_content)] }
  end

  factory :island_type, class: CardType do
    contents { [association(:island_content)] }
  end

  factory :darkbore_pathway_type, class: CardType do
    contents { [association(:darkbore_pathway_content), association(:slitherbore_pathway_content)] }
  end
  factory :jungle_hollow_type, class: CardType do
    contents { [association(:jungle_hollow_content)] }
  end

  factory :deathcap_glade_type, class: CardType do
    contents { [association(:deathcap_glade_content)] }
  end

  factory :obscura_storefront_type, class: CardType do
    contents { [association(:obscura_storefront_content)] }
  end
  
end
